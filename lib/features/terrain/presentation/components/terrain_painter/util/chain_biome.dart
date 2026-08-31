import 'dart:ui' as ui;

import '../../../../../../core/pathfinding/grid.dart';
import '../../../../domain/models/biome.dart';
import '../../../../domain/models/terrain_map.dart';

/// Resolves the brush-type [Biome] painted at a chain's first point, for
/// tinting that river ribbon - falls back to the map's own biome when the
/// point falls outside the grid (e.g. an edge-extended chain endpoint).
Biome chainBiome(TerrainMap terrainMap, Grid grid, List<ui.Offset> chain) {
  final first = chain.first;
  final col = (first.dx / grid.cellSize).floor().clamp(0, grid.cols - 1);
  final row = (first.dy / grid.cellSize).floor().clamp(0, grid.rows - 1);
  return terrainMap.biomeAt(col, row);
}
