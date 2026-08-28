import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/team.dart';

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
        size: Vector2.all(hullSize.y * 0.4),
        priority: 6,
      );

  @override
  void update(double dt) {
    super.update(dt);
    _phase += dt * 2.6;
  }

  @override
  void render(Canvas canvas) {
    final pulse = 0.5 + 0.5 * sin(_phase);
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x * 0.5;

    canvas.drawCircle(
      center,
      radius * (1.3 + pulse * 0.4),
      Paint()
        ..color = accent.withValues(alpha: 0.2 + pulse * 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.6),
    );
    canvas.drawCircle(
      center,
      radius * (0.7 + pulse * 0.3),
      Paint()..color = accent.withValues(alpha: 0.75 + pulse * 0.25),
    );
  }
}
