import 'dart:ui' as ui;

/// Paints a single drifting snow flurry dot.
void paintSnowParticle(
  ui.Canvas canvas, {
  required double x,
  required double y,
  required double scale,
  required double opacity,
}) {
  canvas.drawCircle(
    ui.Offset(x, y),
    2.5 * scale,
    ui.Paint()..color = const ui.Color(0xFFFFFFFF).withValues(alpha: opacity),
  );
}
