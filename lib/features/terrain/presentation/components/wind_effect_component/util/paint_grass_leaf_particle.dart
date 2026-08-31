import 'dart:ui' as ui;

/// Paints a single blown grass-clipping streak.
void paintGrassLeafParticle(
  ui.Canvas canvas, {
  required double x,
  required double y,
  required double scale,
  required double opacity,
}) {
  final center = ui.Offset(x, y);
  final paint = ui.Paint()
    ..color = const ui.Color(0xFFB7C97A).withValues(alpha: opacity)
    ..strokeWidth = 2 * scale
    ..strokeCap = ui.StrokeCap.round;
  canvas.drawLine(center, center.translate(-14 * scale, 4 * scale), paint);
}
