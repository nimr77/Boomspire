import 'dart:math';

import '../../../core/pathfinding/grid.dart';
import '../../game_core/domain/models/game_config.dart';
import '../domain/models/biome.dart';
import '../domain/models/obstacle_kind.dart';
import '../domain/models/terrain_map.dart';
import '../domain/repos/terrain_repository.dart';

/// Builds a biome-flavored terrain: scattered high-ground obstacles
/// (mountains or dunes) plus a winding impassable crossing (river or dry
/// valley), with a guaranteed-clear route between spawn and base. Every
/// other cell is buildable.
class TerrainRepositoryImpl implements TerrainRepository {
  static const arenaWidth = GameConfig.arenaWidth;
  static const arenaHeight = GameConfig.arenaHeight;
  static const cellSize = 40.0;

  @override
  TerrainMap loadTerrain({required Biome biome}) {
    final cols = (arenaWidth / cellSize).round();
    final rows = (arenaHeight / cellSize).round();
    final grid = Grid(cols: cols, rows: rows, cellSize: cellSize);
    final obstacleKinds = List.generate(
      rows,
      (_) => List<ObstacleKind?>.filled(cols, null),
    );

    final spawnCell = Point(0, rows ~/ 2);
    final baseCell = Point(cols - 1, rows ~/ 2);
    final palette = biome.palette;
    final rnd = Random(1337 + biome.index * 97);

    _scatterHighGround(
      grid,
      obstacleKinds,
      rnd,
      spawnCell,
      baseCell,
      palette.highGround,
    );
    _carveWindingObstacle(
      grid,
      obstacleKinds,
      rnd,
      palette.crossing,
      spawnCell,
      baseCell,
    );
    _ensureReachable(grid, obstacleKinds, spawnCell, baseCell);

    return TerrainMap(
      arenaWidth: arenaWidth,
      arenaHeight: arenaHeight,
      grid: grid,
      biome: biome,
      obstacleKinds: obstacleKinds,
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

  /// Carves a winding impassable river/valley from the top edge to the
  /// bottom edge, forcing the player to route towers around a natural
  /// barrier instead of just scattered blobs.
  void _carveWindingObstacle(
    Grid grid,
    List<List<ObstacleKind?>> kinds,
    Random rnd,
    ObstacleKind kind,
    Point<int> spawnCell,
    Point<int> baseCell,
  ) {
    const protectedRadius = 2;
    var col = 4 + rnd.nextInt((grid.cols - 8).clamp(1, grid.cols));

    for (var row = 0; row < grid.rows; row++) {
      final width = 1 + rnd.nextInt(2);
      for (var w = -(width ~/ 2); w <= width ~/ 2; w++) {
        final x = (col + w).clamp(0, grid.cols - 1);
        if (_withinRadius(x, row, spawnCell, protectedRadius) ||
            _withinRadius(x, row, baseCell, protectedRadius)) {
          continue;
        }
        grid.setMountain(x, row, true);
        kinds[row][x] = kind;
      }
      col = (col + rnd.nextInt(3) - 1).clamp(2, grid.cols - 3);
    }
  }

  /// Guarantees a path exists by carving a straight horizontal corridor
  /// through the spawn row if the random scatter sealed it off.
  void _ensureReachable(
    Grid grid,
    List<List<ObstacleKind?>> kinds,
    Point<int> spawnCell,
    Point<int> baseCell,
  ) {
    if (grid.isReachable(spawnCell, baseCell)) return;
    final row = spawnCell.y;
    for (var col = 0; col < grid.cols; col++) {
      grid.setMountain(col, row, false);
      kinds[row][col] = null;
    }
  }

  void _scatterHighGround(
    Grid grid,
    List<List<ObstacleKind?>> kinds,
    Random rnd,
    Point<int> spawnCell,
    Point<int> baseCell,
    ObstacleKind kind,
  ) {
    const clusterCount = 14;
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
          if (rnd.nextDouble() < 0.78) {
            grid.setMountain(x, y, true);
            kinds[y][x] = kind;
          }
        }
      }
    }
  }

  bool _withinRadius(int x, int y, Point<int> center, int radius) {
    final dx = x - center.x;
    final dy = y - center.y;
    return dx * dx + dy * dy <= radius * radius;
  }
}
