import 'dart:ui' as ui;

import '../../../../../../core/pathfinding/grid.dart';
import '../../../../domain/models/obstacle_kind.dart';

/// Pseudo-3D contact shadow pass for `TerrainPainter.paint`: every
/// mountain/dune cell drops a soft dark shadow offset down-right (fake sun
/// direction) before the shape itself is painted, giving the ridge/dune a
/// sense of elevation.
void paintMountainDuneShadows(
  ui.Canvas canvas,
  Grid grid,
  List<List<ObstacleKind?>> kinds,
) {
  for (var row = 0; row < grid.rows; row++) {
    for (var col = 0; col < grid.cols; col++) {
      final kind = kinds[row][col];
      if (kind != ObstacleKind.mountain && kind != ObstacleKind.dune) {
        continue;
      }
      final cx = col * grid.cellSize + grid.cellSize / 2;
      final cy = row * grid.cellSize + grid.cellSize / 2;
      canvas.drawCircle(
        ui.Offset(cx + 5, cy + 8),
        grid.cellSize * 0.42,
        ui.Paint()
          ..color = const ui.Color(0xFF000000).withValues(alpha: 0.28)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
      );
    }
  }
}
