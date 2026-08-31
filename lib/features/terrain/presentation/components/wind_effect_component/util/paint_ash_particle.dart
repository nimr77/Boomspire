import 'dart:ui' as ui;

/// Paints a single drifting ash particle - alternates fleck vs. smudge by
/// [colorIndex] parity (fixed at spawn, not re-randomized every frame) so
/// each piece of ash keeps its own identity as it drifts with the gust.
void paintAshParticle(
  ui.Canvas canvas, {
  required double x,
  required double y,
  required double scale,
  required double opacity,
  required int colorIndex,
}) {
  final center = ui.Offset(x, y);
  if (colorIndex.isEven) {
    canvas.drawCircle(
      center,
      1.6 * scale,
      ui.Paint()
        ..color = ui.Color.lerp(
          const ui.Color(0xFF9e9e9e),
          const ui.Color(0xFF2b2b2b),
          opacity,
        )!.withValues(alpha: opacity),
    );
  } else {
    canvas.drawLine(
      center,
      center.translate(-10 * scale, 3 * scale),
      ui.Paint()
        ..color = const ui.Color(0xFF4a3524).withValues(alpha: opacity)
        ..strokeWidth = 1.4 * scale
        ..strokeCap = ui.StrokeCap.round,
    );
  }
}
