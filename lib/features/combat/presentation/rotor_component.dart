import 'dart:ui';

import 'package:flame/components.dart';

/// Always-spinning main rotor blur disc, layered above a helicopter-kind
/// unit's static fuselage sprite so it reads as "alive" even while idling -
/// attached via `MobileUnitComponent.addExtraVisuals`.
class RotorComponent extends PositionComponent {
  double _spin = 0;

  RotorComponent({required Vector2 position})
    : super(
        position: position + Vector2(0, -position.y * 0.7),
        anchor: Anchor.center,
        size: Vector2.all(position.x * 1.9),
        priority: 5,
      );

  @override
  void render(Canvas canvas) {
    final center = size / 2;
    canvas.save();
    canvas.translate(center.x, center.y);
    canvas.rotate(_spin);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y * 0.1),
      Paint()..color = const Color(0x66B0BEC5),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.x * 0.1, height: size.y),
      Paint()..color = const Color(0x66B0BEC5),
    );
    canvas.restore();
    canvas.drawCircle(
      Offset(center.x, center.y),
      size.x * 0.04,
      Paint()..color = const Color(0xFF1a1c20),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spin += dt * 18;
  }
}
