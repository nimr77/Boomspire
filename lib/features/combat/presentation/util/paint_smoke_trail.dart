import 'dart:ui';

/// Paints one frame of `SmokeTrailComponent`'s fading puff.
void paintSmokeTrail(
  Canvas canvas, {
  required double age,
  required double duration,
}) {
  final t = (age / duration).clamp(0.0, 1.0);
  canvas.drawCircle(
    Offset.zero,
    5 + t * 6,
    Paint()
      ..color = Color.lerp(
        const Color(0xAA9E9E9E),
        const Color(0x009E9E9E),
        t,
      )!,
  );
}
