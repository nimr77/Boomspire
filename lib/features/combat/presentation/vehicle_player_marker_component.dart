import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/team.dart';

/// Static team-color roundel mounted on a ground vehicle's hull - a plain
/// ownership marker (no aiming, no weapon), replacing the old gun-turret
/// overlay that added no real gameplay value.
class VehiclePlayerMarkerComponent extends PositionComponent {
  final Color accent;

  VehiclePlayerMarkerComponent({required Vector2 hullSize, required Team team})
    : accent = team.color,
      super(
        position: hullSize / 2,
        anchor: Anchor.center,
        size: Vector2.all(hullSize.x * 0.3),
        priority: 6,
      );

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF2B2E33));
    canvas.drawCircle(center, radius * 0.68, Paint()..color = accent);
  }
}
