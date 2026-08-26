import 'dart:ui';

import 'package:flame/components.dart';

/// A single frame of the "breaking the air" streak a fast fixed-wing enemy
/// leaves behind it - a short, fading vapor cone aligned to its heading.
class VaporConeComponent extends PositionComponent {
  static const _duration = 0.35;

  final double coneAngle;
  double _age = 0;

  VaporConeComponent({required Vector2 position, required double angle})
    : coneAngle = angle,
      super(position: position, anchor: Anchor.center, priority: 3);

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final fade = 1 - t;
    final length = 26 + t * 10;
    final width = 5 + t * 9;

    canvas.save();
    canvas.rotate(coneAngle + 3.14159);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(length, -width / 2)
      ..lineTo(length * 1.3, 0)
      ..lineTo(length, width / 2)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFEFF7FF).withValues(alpha: 0.4 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
