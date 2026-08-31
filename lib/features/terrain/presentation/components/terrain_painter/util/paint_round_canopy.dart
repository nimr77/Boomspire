import 'dart:ui' as ui;

import 'paint_trunk.dart';

/// The default grassland canopy: rounded, overlapping foliage blobs
/// instead of flat pine tiers - a cluster of clumps reads as a top-down
/// tree canopy, RA2-style.
void paintRoundCanopy(ui.Canvas canvas, double cx, double cy, double scale) {
  paintTrunk(canvas, cx, cy, scale);
  const lobes = [
    (dx: 0.0, dy: -2.0, scale: 1.0),
    (dx: -6.0, dy: 2.0, scale: 0.75),
    (dx: 6.0, dy: 2.0, scale: 0.8),
    (dx: 0.0, dy: 5.0, scale: 0.85),
  ];
  for (final lobe in lobes) {
    final lobeCenter = ui.Offset(
      cx + lobe.dx * scale,
      cy + lobe.dy * scale - 4 * scale,
    );
    final radius = 9 * scale * lobe.scale;
    canvas.drawCircle(
      lobeCenter,
      radius,
      ui.Paint()..color = const ui.Color(0xFF1f3d22).withValues(alpha: 0.92),
    );
  }
  // Single highlight blob (fake sun from top-left) so the canopy isn't
  // one flat silhouette.
  canvas.drawCircle(
    ui.Offset(cx - 5 * scale, cy - 8 * scale),
    6 * scale,
    ui.Paint()..color = const ui.Color(0xFF3f6b3f).withValues(alpha: 0.6),
  );
}
