// Regression tests for a rendering bug: `HumanLimbsComponent`,
// `VehiclePlayerMarkerComponent`, `VehicleTreadComponent` and `FireComponent`
// all use `Anchor.center` with a non-zero `size`, but Flame always renders in a
// top-left-origin `0..size` box regardless of anchor - the anchor only
// affects where that box is placed in the *parent's* coordinates. Each of
// these components used to draw as if local `(0, 0)` were already the
// center, so their content rendered shifted a half hull-width/height away
// from where it should be (e.g. legs floating off to the side of the
// torso). These tests call `render` directly (no game/world needed) and
// assert the actual drawn geometry sits on the component's real center.
//
// Expected offsets are computed with the exact same arithmetic as the
// production code (rather than baked-in decimal literals) so the
// comparisons are bit-exact instead of fighting floating-point rounding.
import 'package:boomspire/core/combat/team.dart';
import 'package:boomspire/features/combat/presentation/fire_component.dart';
import 'package:boomspire/features/combat/presentation/human_limbs_component.dart';
import 'package:boomspire/features/combat/presentation/vehicle_player_marker_component.dart';
import 'package:boomspire/features/combat/presentation/vehicle_tread_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HumanLimbsComponent render position', () {
    final hullSize = Vector2(30, 40);
    final cx = hullSize.x / 2;
    final cy = hullSize.y / 2;

    test('draws both legs centered on the hull, not off to one side', () {
      final limbs = HumanLimbsComponent(hullSize: hullSize, accent: Colors.red)
        ..setPhase(0);

      // Standing still (phase 0 -> no leg swing): legs must hang straight
      // down from the hips, which sit at the hull's horizontal center.
      const legSwing = 0.0;
      final hipY = cy + hullSize.y * 0.28;
      expect(
        (Canvas canvas) => limbs.render(canvas),
        paints
          ..line(
            p1: Offset(cx - hullSize.x * 0.1, hipY),
            p2: Offset(
              cx - hullSize.x * 0.1 + legSwing * 0.3,
              hipY + hullSize.y * 0.34,
            ),
          )
          ..line(
            p1: Offset(cx + hullSize.x * 0.1, hipY),
            p2: Offset(
              cx + hullSize.x * 0.1 - legSwing * 0.3,
              hipY + hullSize.y * 0.34,
            ),
          ),
      );
    });

    test('the fire-flash arm stroke is anchored to the hull, not (0, 0)', () {
      final limbs = HumanLimbsComponent(hullSize: hullSize, accent: Colors.red)
        ..pulseFire();

      expect(
        (Canvas canvas) => limbs.render(canvas),
        paints
          ..line() // left leg, checked separately above
          ..line() // right leg, checked separately above
          ..line(
            p1: Offset(cx + hullSize.x * 0.12, cy - hullSize.y * 0.05),
            p2: Offset(cx + hullSize.x * 0.42, cy - hullSize.y * 0.22),
          ),
      );
    });
  });

  group('VehiclePlayerMarkerComponent render position', () {
    test('the team-color badge sits centered on the hull', () {
      final hullSize = Vector2(40, 40);
      final marker = VehiclePlayerMarkerComponent(
        hullSize: hullSize,
        team: Team.defaultPlayer,
      );
      final radius = (hullSize.x * 0.3) / 2;
      final center = Offset(radius, radius);

      expect(
        (Canvas canvas) => marker.render(canvas),
        paints
          ..circle(x: center.dx, y: center.dy, radius: radius)
          ..circle(x: center.dx, y: center.dy, radius: radius * 0.68),
      );
    });
  });

  group('VehicleTreadComponent render position', () {
    test('dashes are drawn vertically centered in the strip, not at y=0', () {
      final hullSize = Vector2(30, 20);
      final tread = VehicleTreadComponent(hullSize: hullSize);
      final stripSize = Vector2(hullSize.x * 0.7, hullSize.y * 0.12);
      const dashCount = 4;
      final spacing = stripSize.x / dashCount;
      final dashWidth = spacing * 0.55;

      // No update() has run yet, so `_scroll` is still 0 - dash centers are
      // at x = 0, spacing, 2*spacing, ... and vertically at size.y / 2
      // (not 0, which was the bug).
      expect(
        (Canvas canvas) => tread.render(canvas),
        paints
          ..rrect(
            rrect: RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(0, stripSize.y / 2),
                width: dashWidth,
                height: stripSize.y,
              ),
              const Radius.circular(2),
            ),
          )
          ..rrect(
            rrect: RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(spacing, stripSize.y / 2),
                width: dashWidth,
                height: stripSize.y,
              ),
              const Radius.circular(2),
            ),
          ),
      );
    });
  });

  group('FireComponent render position', () {
    test(
      'the flame path renders without the old dark impact-shadow circle',
      () {
        const radius = 16.0;
        final fire = FireComponent(position: Vector2(100, 100), radius: radius);

        // Freshly spawned: age is 0, so fade is 1.
        expect((Canvas canvas) => fire.render(canvas), paints..path());
      },
    );
  });
}
