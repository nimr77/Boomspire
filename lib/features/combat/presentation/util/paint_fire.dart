import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Paints one frame of `FireComponent`'s flickering flame shape.
void paintFire(
  Canvas canvas, {
  required Vector2 size,
  required double age,
  required double flicker,
  required double duration,
}) {
  final t = (age / duration).clamp(0.0, 1.0);
  final fade = 1 - t;
  if (fade <= 0) return;
  final wobble = sin(flicker * 9) * size.x * 0.06;
  final h = size.x * (0.55 + sin(flicker * 7) * 0.08);
  // Flame's render box is top-left-origin, so the flame must be built
  // around (cx, cy) rather than (0, 0) to sit on the impact point.
  final cx = size.x / 2;
  final cy = size.y / 2;
  final path = Path()
    ..moveTo(cx, cy + size.x * 0.3)
    ..quadraticBezierTo(
      cx + size.x * 0.28 + wobble,
      cy + size.x * 0.05,
      cx,
      cy - h,
    )
    ..quadraticBezierTo(
      cx - size.x * 0.28 + wobble,
      cy + size.x * 0.05,
      cx,
      cy + size.x * 0.3,
    )
    ..close();
  canvas.drawPath(
    path,
    Paint()
      ..color = Color.lerp(
        const Color(0xFFFF7043),
        const Color(0x00FF7043),
        t,
      )!.withValues(alpha: 0.85 * fade)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
  );
}
