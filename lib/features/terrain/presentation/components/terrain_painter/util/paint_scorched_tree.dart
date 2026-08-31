import 'dart:ui' as ui;

/// A handful of bare, blackened branches - a scorched tree among the
/// ruins, no living canopy left.
void paintScorchedTree(ui.Canvas canvas, double cx, double cy, double scale) {
  final paint = ui.Paint()
    ..color = const ui.Color(0xFF2a2622)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 2.4 * scale
    ..strokeCap = ui.StrokeCap.round;
  final base = ui.Offset(cx, cy + 8 * scale);
  final mid = ui.Offset(cx - 1 * scale, cy - 3 * scale);
  canvas.drawLine(base, mid, paint);
  for (final branch in [
    ui.Offset(cx - 10 * scale, cy - 7 * scale),
    ui.Offset(cx + 7 * scale, cy - 10 * scale),
    ui.Offset(cx + 2 * scale, cy - 13 * scale),
  ]) {
    canvas.drawLine(mid, branch, paint);
  }
  canvas.drawCircle(
    mid,
    2 * scale,
    ui.Paint()..color = const ui.Color(0xFF5c3f2e).withValues(alpha: 0.4),
  );
}
