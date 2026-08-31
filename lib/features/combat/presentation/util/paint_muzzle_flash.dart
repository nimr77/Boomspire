import 'dart:math';
import 'dart:ui';

/// Paints one frame of a `MuzzleFlashComponent`: the fading flash circle
/// plus the radiating spark lines, at animation progress [t] (0..1).
void paintMuzzleFlash(
  Canvas canvas, {
  required double t,
  required List<double> sparkAngles,
}) {
  canvas.drawCircle(
    Offset.zero,
    8 * (1 - t),
    Paint()
      ..color = Color.lerp(
        const Color(0xFFFFF6D8),
        const Color(0x00FFB703),
        t,
      )!,
  );

  final sparkPaint = Paint()
    ..color = Color.lerp(const Color(0xFFFFE082), const Color(0x00FFB703), t)!
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  final sparkLength = 12 * (1 - t);
  for (final a in sparkAngles) {
    canvas.drawLine(
      Offset.zero,
      Offset(cos(a), sin(a)) * sparkLength,
      sparkPaint,
    );
  }
}
