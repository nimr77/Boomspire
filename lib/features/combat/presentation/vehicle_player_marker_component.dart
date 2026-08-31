import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/team.dart';
import 'util/paint_vehicle_player_marker.dart';

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
  void render(Canvas canvas) =>
      paintVehiclePlayerMarker(canvas, size: size, accent: accent);
}
