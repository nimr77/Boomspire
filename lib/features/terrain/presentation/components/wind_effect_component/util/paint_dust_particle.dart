import 'dart:ui' as ui;

/// Paints a single blown-dust streak.
void paintDustParticle(
  ui.Canvas canvas, {
  required double x,
  required double y,
  required double scale,
  required double opacity,
}) {
  final center = ui.Offset(x, y);
  final paint = ui.Paint()
    ..color = const ui.Color(0xFFDCD3B8).withValues(alpha: opacity * 0.7)
    ..strokeWidth = 1.2 * scale
    ..strokeCap = ui.StrokeCap.round;
  canvas.drawLine(center, center.translate(-16 * scale, 0), paint);
}
