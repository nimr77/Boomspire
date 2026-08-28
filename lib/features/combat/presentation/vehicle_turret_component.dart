import 'dart:ui';

import 'package:flame/components.dart';

/// Independently-rotating weapon overlay for ground vehicles (tanks, rocket
/// trucks) - drawn on top of the vehicle's flat hull sprite so the "turret"
/// can track a target/heading without spinning the whole hull, the same
/// idea as `TowerComponent.turret` but for a mobile unit.
class VehicleTurretComponent extends PositionComponent {
  final Color accent;

  VehicleTurretComponent({required Vector2 hullSize, required this.accent})
    : super(
        position: hullSize / 2,
        anchor: Anchor.center,
        size: Vector2(hullSize.x * 0.62, hullSize.x * 0.3),
        priority: 6,
      );

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    // Flame's render box is top-left-origin (0..w, 0..h), not centered on
    // the anchor - the pivot ring/barrel base must be drawn at (w/2, h/2)
    // to actually sit on the hull's center instead of off to one side.
    final pivot = Offset(w / 2, h / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pivot, width: h * 1.6, height: h * 1.6),
        Radius.circular(h * 0.5),
      ),
      Paint()..color = const Color(0xFF3B3F45),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pivot.dx, pivot.dy - h * 0.22, w, h * 0.44),
        Radius.circular(h * 0.2),
      ),
      Paint()..color = accent.withValues(alpha: 0.9),
    );
  }
}
