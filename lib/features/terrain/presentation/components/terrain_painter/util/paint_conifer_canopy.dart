import 'dart:ui' as ui;

import 'paint_trunk.dart';

/// Layered conical tiers (blue-white, snow-capped) for the icy peaks -
/// distinct from the tundra's frosted broadleaf look.
void paintConiferCanopy(ui.Canvas canvas, double cx, double cy, double scale) {
  paintTrunk(canvas, cx, cy, scale, height: 8, color: 0xFF3a3228);
  const tiers = [0.0, -5.0, -9.5];
  for (final dy in tiers) {
    final width = (16 - tiers.indexOf(dy) * 3) * scale;
    final tierCenter = ui.Offset(cx, cy + dy * scale - 3 * scale);
    final path = ui.Path()
      ..moveTo(tierCenter.dx - width / 2, tierCenter.dy + 4 * scale)
      ..lineTo(tierCenter.dx, tierCenter.dy - 5 * scale)
      ..lineTo(tierCenter.dx + width / 2, tierCenter.dy + 4 * scale)
      ..close();
    canvas.drawPath(
      path,
      ui.Paint()..color = const ui.Color(0xFF375a52).withValues(alpha: 0.9),
    );
  }
  canvas.drawCircle(
    ui.Offset(cx, cy - 12.5 * scale),
    3.2 * scale,
    ui.Paint()..color = const ui.Color(0xFFFFFFFF).withValues(alpha: 0.85),
  );
}
