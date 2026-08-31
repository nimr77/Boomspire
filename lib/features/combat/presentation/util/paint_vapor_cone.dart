import 'dart:ui';

/// Paints one frame of `VaporConeComponent`'s fading vapor streak.
void paintVaporCone(
  Canvas canvas, {
  required double age,
  required double duration,
  required double coneAngle,
}) {
  final t = (age / duration).clamp(0.0, 1.0);
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
