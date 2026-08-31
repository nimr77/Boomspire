import 'dart:ui';

import 'package:flame/components.dart';

/// Paints a `BulletComponent`'s glow + tracer body.
void paintBullet(Canvas canvas, {required Vector2 size, required Color color}) {
  final glow = Paint()
    ..color = color.withValues(alpha: 0.35)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  canvas.drawCircle(Offset(size.x / 2, size.y / 2), 5, glow);
  canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = color);
}
