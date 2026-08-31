import 'dart:ui' as ui;

import 'paint_trunk.dart';

/// A flattened, wide-spread canopy on a taller trunk - reads as an acacia
/// silhouette against open savanna grassland.
void paintAcaciaCanopy(ui.Canvas canvas, double cx, double cy, double scale) {
  paintTrunk(canvas, cx, cy, scale, height: 12, color: 0xFF5a3f1f);
  canvas.drawOval(
    ui.Rect.fromCenter(
      center: ui.Offset(cx, cy - 11 * scale),
      width: 26 * scale,
      height: 9 * scale,
    ),
    ui.Paint()..color = const ui.Color(0xFF6b7a3d).withValues(alpha: 0.92),
  );
  canvas.drawOval(
    ui.Rect.fromCenter(
      center: ui.Offset(cx - 4 * scale, cy - 13 * scale),
      width: 12 * scale,
      height: 5 * scale,
    ),
    ui.Paint()..color = const ui.Color(0xFF8a9a4a).withValues(alpha: 0.6),
  );
}
