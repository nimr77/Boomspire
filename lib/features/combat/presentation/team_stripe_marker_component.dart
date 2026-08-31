import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/team.dart';
import 'util/paint_team_stripe_marker.dart';

/// Pulsing team-color light mounted on a plane's hull - the flying-wing
/// body type's analog of [VehiclePlayerMarkerComponent]'s roundel, which
/// doesn't read well on a shape with no flat "deck" to sit on. Deliberately
/// a breathing glow rather than the static stripe/line this used to be -
/// see [JetFlareComponent] for the same "light, not a line" treatment on
/// the engine trail.
class TeamStripeMarkerComponent extends PositionComponent {
  final Color accent;
  double _phase = 0;

  TeamStripeMarkerComponent({required Vector2 hullSize, required Team team})
    : accent = team.color,
      super(
        position: hullSize / 2,
        anchor: Anchor.center,
        size: Vector2.all(hullSize.y * 0.22),
        priority: 6,
      );

  @override
  void render(Canvas canvas) =>
      paintTeamStripeMarker(canvas, size: size, accent: accent, phase: _phase);

  @override
  void update(double dt) {
    super.update(dt);
    _phase += dt * 2.6;
  }
}
