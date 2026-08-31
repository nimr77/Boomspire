import 'dart:math';
import 'dart:ui' as ui;

/// A curved trunk plus radiating frond blades - reads as a palm on the
/// sea biome's coastal reefs/islets.
void paintPalmCanopy(ui.Canvas canvas, double cx, double cy, double scale) {
  final trunkPath = ui.Path()
    ..moveTo(cx - 2 * scale, cy + 9 * scale)
    ..quadraticBezierTo(
      cx + 5 * scale,
      cy + 2 * scale,
      cx + 1 * scale,
      cy - 9 * scale,
    );
  canvas.drawPath(
    trunkPath,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 3 * scale
      ..color = const ui.Color(0xFF8a6a3f),
  );
  final crown = ui.Offset(cx + 1 * scale, cy - 9 * scale);
  for (final angle in [-1.1, -0.5, 0.0, 0.5, 1.1]) {
    final tip = ui.Offset(
      crown.dx + cos(angle) * 13 * scale,
      crown.dy + sin(angle) * 8 * scale - 3 * scale,
    );
    canvas.drawLine(
      crown,
      tip,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2.4 * scale
        ..strokeCap = ui.StrokeCap.round
        ..color = const ui.Color(0xFF2f7a4a),
    );
  }
}
