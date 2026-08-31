import 'dart:ui' as ui;

import '../../../../../../core/pathfinding/grid.dart';
import '../../../../domain/models/obstacle_kind.dart';
import 'chain_cells.dart';
import 'connected_cells.dart';

/// One ordered point-chain per connected group of [kind] cells, so any
/// hand-drawn shape (not just a single top-to-bottom crossing) renders as
/// its actual path rather than collapsing to one line - ordering is
/// reconstructed from real cell adjacency since `TerrainMap` only stores
/// the rasterized grid, not the original drawn stroke. A chain that
/// touches the top/bottom grid edge is extended straight to the matching
/// canvas edge so it doesn't visibly stop short of the border.
List<List<ui.Offset>> obstacleChains(
  Grid grid,
  List<List<ObstacleKind?>> kinds,
  ObstacleKind kind,
  double canvasHeight,
) {
  final chains = <List<ui.Offset>>[];
  for (final component in connectedCells(grid, kinds, kind)) {
    final ordered = chainCells(component);
    if (ordered.isEmpty) continue;
    final points = ordered
        .map(
          (c) => ui.Offset(
            c.x * grid.cellSize + grid.cellSize / 2,
            c.y * grid.cellSize + grid.cellSize / 2,
          ),
        )
        .toList();
    if (ordered.first.y == 0) {
      points.insert(0, ui.Offset(points.first.dx, 0));
    }
    if (ordered.last.y == grid.rows - 1) {
      points.add(ui.Offset(points.last.dx, canvasHeight));
    }
    chains.add(points);
  }
  return chains;
}
