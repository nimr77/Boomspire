import 'dart:ui' as ui;

import 'paint_trunk.dart';

/// Dense, darker overlapping foliage blobs - a thicker rainforest canopy
/// than the default grassland tree.
void paintForestCanopy(ui.Canvas canvas, double cx, double cy, double scale) {
  paintTrunk(canvas, cx, cy, scale);
  const lobes = [
    (dx: 0.0, dy: -3.0, scale: 1.15),
    (dx: -7.0, dy: 1.5, scale: 0.9),
    (dx: 7.0, dy: 1.5, scale: 0.95),
    (dx: -3.0, dy: 5.0, scale: 0.85),
    (dx: 4.0, dy: 5.5, scale: 0.8),
  ];
  for (final lobe in lobes) {
    canvas.drawCircle(
      ui.Offset(cx + lobe.dx * scale, cy + lobe.dy * scale - 4 * scale),
      9 * scale * lobe.scale,
      ui.Paint()..color = const ui.Color(0xFF14311a).withValues(alpha: 0.94),
    );
  }
  canvas.drawCircle(
    ui.Offset(cx - 5 * scale, cy - 9 * scale),
    6 * scale,
    ui.Paint()..color = const ui.Color(0xFF3a7a3f).withValues(alpha: 0.55),
  );
}
