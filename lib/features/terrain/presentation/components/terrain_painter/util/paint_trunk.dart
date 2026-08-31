import 'dart:ui' as ui;

/// Shared trunk shape used by every canopy style except the desert/ruins
/// dead branches and the sea biome's curved palm trunk.
void paintTrunk(
  ui.Canvas canvas,
  double cx,
  double cy,
  double scale, {
  double height = 8,
  int color = 0xFF4a3421,
}) {
  canvas.drawRect(
    ui.Rect.fromCenter(
      center: ui.Offset(cx, cy + (height / 2) * scale),
      width: 3 * scale,
      height: height * scale,
    ),
    ui.Paint()..color = ui.Color(color),
  );
}
