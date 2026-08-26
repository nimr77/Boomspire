import 'dart:math';

import '../../../core/pathfinding/grid.dart';
import '../../game_core/domain/models/game_config.dart';
import '../domain/models/terrain_map.dart';
import '../domain/repos/terrain_repository.dart';

/// Builds the mountain terrain: a grid of impassable peaks scattered across
/// the arena (with a guaranteed-clear route between spawn and base), leaving
/// every other cell open for the player to build on.
class TerrainRepositoryImpl implements TerrainRepository {
  static const arenaWidth = GameConfig.arenaWidth;
  static const arenaHeight = GameConfig.arenaHeight;
  static const cellSize = 40.0;

  @override
  TerrainMap loadTerrain() {
    final cols = (arenaWidth / cellSize).round();
    final rows = (arenaHeight / cellSize).round();
    final grid = Grid(cols: cols, rows: rows, cellSize: cellSize);

    final spawnCell = Point(0, rows ~/ 2);
    final baseCell = Point(cols - 1, rows ~/ 2);

    _scatterMountains(grid, spawnCell, baseCell);
    _ensureReachable(grid, spawnCell, baseCell);

    return TerrainMap(
      arenaWidth: arenaWidth,
      arenaHeight: arenaHeight,
      grid: grid,
      spawnPoint: PathPoint(
        grid.cellCenter(spawnCell).x,
        grid.cellCenter(spawnCell).y,
      ),
      basePoint: PathPoint(
        grid.cellCenter(baseCell).x,
        grid.cellCenter(baseCell).y,
      ),
    );
  }

  void _scatterMountains(Grid grid, Point<int> spawnCell, Point<int> baseCell) {
    final rnd = Random(1337);
    const clusterCount = 16;
    const protectedRadius = 2;

    for (var c = 0; c < clusterCount; c++) {
      final cx = rnd.nextInt(grid.cols);
      final cy = rnd.nextInt(grid.rows);
      final blobRadius = 1 + rnd.nextInt(3);

      for (var dy = -blobRadius; dy <= blobRadius; dy++) {
        for (var dx = -blobRadius; dx <= blobRadius; dx++) {
          if (dx * dx + dy * dy > blobRadius * blobRadius) continue;
          final x = cx + dx;
          final y = cy + dy;
          if (!grid.inBounds(x, y)) continue;

          if (_withinRadius(x, y, spawnCell, protectedRadius) ||
              _withinRadius(x, y, baseCell, protectedRadius)) {
            continue;
          }
          if (rnd.nextDouble() < 0.8) grid.setMountain(x, y, true);
        }
      }
    }
  }

  bool _withinRadius(int x, int y, Point<int> center, int radius) {
    final dx = x - center.x;
    final dy = y - center.y;
    return dx * dx + dy * dy <= radius * radius;
  }

  /// Guarantees a path exists by carving a straight horizontal corridor
  /// through the spawn row if the random scatter sealed it off.
  void _ensureReachable(Grid grid, Point<int> spawnCell, Point<int> baseCell) {
    if (grid.isReachable(spawnCell, baseCell)) return;
    final row = spawnCell.y;
    for (var col = 0; col < grid.cols; col++) {
      grid.setMountain(col, row, false);
    }
  }
}

