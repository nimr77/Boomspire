import 'dart:ui' as ui;

/// Paints a single blown-sand streak.
void paintSandParticle(
  ui.Canvas canvas, {
  required double x,
  required double y,
  required double scale,
  required double opacity,
}) {
  final center = ui.Offset(x, y);
  final paint = ui.Paint()
    ..color = const ui.Color(0xFFD8C08A).withValues(alpha: opacity)
    ..strokeWidth = 1.5 * scale
    ..strokeCap = ui.StrokeCap.round;
  canvas.drawLine(center, center.translate(-22 * scale, 0), paint);
}
