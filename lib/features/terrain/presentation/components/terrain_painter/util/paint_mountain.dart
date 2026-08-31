import 'dart:math';
import 'dart:ui' as ui;

import '../../../../../../core/pathfinding/grid.dart';
import '../../../../domain/models/biome.dart';

/// Bakes one mountain cell's jagged peak silhouette, rock texture and snow
/// cap, seeded per-cell (not per-frame) so texture stays stable across
/// rebuilds instead of re-randomizing every bake.
void paintMountain(
  ui.Canvas canvas,
  Grid grid,
  int col,
  int row,
  BiomePalette palette,
) {
  final cx = col * grid.cellSize + grid.cellSize / 2;
  final cy = row * grid.cellSize + grid.cellSize / 2;
  final half = grid.cellSize / 2;
  final rnd = Random(col * 92821 + row * 68917 + 1);
  double j() => (rnd.nextDouble() - 0.5) * half * 0.22;

  final path = ui.Path()
    ..moveTo(cx + j(), cy - half * 1.05 + j())
    ..lineTo(cx + half * 0.95 + j(), cy + half * 0.85 + j())
    ..lineTo(cx - half * 0.95 + j(), cy + half * 0.85 + j())
    ..close();

  // Soft, wide, blurred underlay so the peak's silhouette melts into the
  // surrounding ground texture instead of reading as a pasted-on sticker
  // shape - this is the main "on the terrain, not a shape" fix.
  canvas.drawPath(
    path,
    ui.Paint()
      ..color = palette.ridgeDark.withValues(alpha: 0.5)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8),
  );

  canvas.drawShadow(path, const ui.Color(0xFF000000), 3, false);
  canvas.drawPath(
    path,
    ui.Paint()
      ..shader = ui.Gradient.linear(
        ui.Offset(cx, cy - half),
        ui.Offset(cx, cy + half),
        [palette.ridgeLight, palette.ridgeDark],
      ),
  );

  // Rocky texture dabs clipped to the silhouette so the face reads as a
  // painted rock surface instead of a flat gradient fill.
  for (var i = 0; i < 12; i++) {
    final px = cx + (rnd.nextDouble() - 0.5) * half * 1.6;
    final py = cy - half * 0.7 + rnd.nextDouble() * half * 1.5;
    if (!path.contains(ui.Offset(px, py))) continue;
    canvas.drawCircle(
      ui.Offset(px, py),
      1.2 + rnd.nextDouble() * 2.2,
      ui.Paint()
        ..color = (rnd.nextBool() ? palette.ridgeLight : palette.ridgeDark)
            .withValues(alpha: 0.24),
    );
  }

  final snowCap = ui.Path()
    ..moveTo(cx + j(), cy - half * 1.05)
    ..lineTo(cx + half * 0.4, cy - half * 0.2)
    ..lineTo(cx - half * 0.4, cy - half * 0.2)
    ..close();
  canvas.drawPath(
    snowCap,
    ui.Paint()
      ..color = palette.capColor.withValues(alpha: 0.78)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.2),
  );
  canvas.drawPath(
    path,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const ui.Color(0xFF1c2126).withValues(alpha: 0.4),
  );
}
