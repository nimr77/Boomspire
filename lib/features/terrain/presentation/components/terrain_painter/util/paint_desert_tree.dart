import 'dart:ui' as ui;

/// A couple of leafless, forked branches - no canopy - for the arid dunes.
void paintDesertTree(ui.Canvas canvas, double cx, double cy, double scale) {
  final paint = ui.Paint()
    ..color = const ui.Color(0xFF7a5c3d)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 2.2 * scale
    ..strokeCap = ui.StrokeCap.round;
  final base = ui.Offset(cx, cy + 8 * scale);
  final mid = ui.Offset(cx, cy - 2 * scale);
  canvas.drawLine(base, mid, paint);
  for (final branch in [
    ui.Offset(cx - 9 * scale, cy - 9 * scale),
    ui.Offset(cx + 8 * scale, cy - 8 * scale),
    ui.Offset(cx - 3 * scale, cy - 12 * scale),
  ]) {
    canvas.drawLine(mid, branch, paint);
  }
}
