import 'dart:math';

import '../../../core/pathfinding/grid.dart';
import '../../game_core/domain/models/game_config.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../domain/models/biome.dart';
import '../domain/models/obstacle_kind.dart';
import '../domain/models/terrain_map.dart';
import '../domain/repos/terrain_repository.dart';

/// Builds a scene-flavored terrain: scattered high-ground obstacles
/// (mountains or dunes) plus a winding impassable crossing (river or dry
/// valley), with a guaranteed-clear route from every spawn point to the
/// base. Every other cell is buildable.
///
/// The base position and the number/direction of spawn points are driven by
/// the scene's [HomeLayout]/[SpawnLayout] - the home doesn't have to sit on
/// the east edge and enemies aren't limited to a single approach.
class TerrainRepositoryImpl implements TerrainRepository {
  static const arenaWidth = GameConfig.arenaWidth;
  static const arenaHeight = GameConfig.arenaHeight;
  static const cellSize = 40.0;

  @override
  TerrainMap loadTerrain({required GameScene scene}) {
    final cols = (arenaWidth / cellSize).round();
    final rows = (arenaHeight / cellSize).round();
    final grid = Grid(cols: cols, rows: rows, cellSize: cellSize);
    final obstacleKinds = List.generate(
      rows,
      (_) => List<ObstacleKind?>.filled(cols, null),
    );

    final baseCell = _baseCell(scene.homeLayout, cols, rows);
    final spawnCells = _spawnCells(scene.spawnLayout, baseCell, cols, rows);
    final protectedCells = [baseCell, ...spawnCells];
    final palette = scene.biome.palette;
    final seed =
        1337 +
        scene.biome.index * 97 +
        scene.homeLayout.index * 31 +
        scene.spawnLayout.index * 7;
    final rnd = Random(seed);

    _scatterHighGround(
      grid,
      obstacleKinds,
      rnd,
      protectedCells,
      palette.highGround,
    );
    _carveWindingObstacle(
      grid,
      obstacleKinds,
      rnd,
      palette.crossing,
      protectedCells,
    );
    _ensureReachable(grid, obstacleKinds, spawnCells, baseCell);

    return TerrainMap(
      arenaWidth: arenaWidth,
      arenaHeight: arenaHeight,
      grid: grid,
      biome: scene.biome,
      obstacleKinds: obstacleKinds,
      spawnPoints: spawnCells
          .map((c) => PathPoint(grid.cellCenter(c).x, grid.cellCenter(c).y))
          .toList(),
      basePoint: PathPoint(
        grid.cellCenter(baseCell).x,
        grid.cellCenter(baseCell).y,
      ),
    );
  }

  Point<int> _baseCell(HomeLayout layout, int cols, int rows) => switch (layout) {
    HomeLayout.eastEdge => Point(cols - 1, rows ~/ 2),
    HomeLayout.center => Point(cols ~/ 2, rows ~/ 2),
    HomeLayout.northEastCorner => Point(cols - 2, 1),
    HomeLayout.southWestCorner => Point(1, rows - 2),
  };

  /// Candidate perimeter approach points (west/east/north/south edge
  /// midpoints), farthest from the base first, excluding the base itself.
  List<Point<int>> _spawnCells(
    SpawnLayout layout,
    Point<int> base,
    int cols,
    int rows,
  ) {
    final candidates = <Point<int>>[
      Point(0, rows ~/ 2), // west
      Point(cols - 1, rows ~/ 2), // east
      Point(cols ~/ 2, 0), // north
      Point(cols ~/ 2, rows - 1), // south
    ]..removeWhere((p) => p == base);

    candidates.sort((a, b) => _distSq(b, base).compareTo(_distSq(a, base)));

    return switch (layout) {
      SpawnLayout.single => [candidates.first],
      SpawnLayout.twoSided => candidates.take(2).toList(),
      SpawnLayout.surround => candidates,
    };
  }

  int _distSq(Point<int> a, Point<int> b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return dx * dx + dy * dy;
  }

  /// Carves a winding impassable river/valley from the top edge to the
  /// bottom edge, forcing the player to route towers around a natural
  /// barrier instead of just scattered blobs.
  void _carveWindingObstacle(
    Grid grid,
    List<List<ObstacleKind?>> kinds,
    Random rnd,
    ObstacleKind kind,
    List<Point<int>> protectedCells,
  ) {
    const protectedRadius = 2;
    var col = 4 + rnd.nextInt((grid.cols - 8).clamp(1, grid.cols));

    for (var row = 0; row < grid.rows; row++) {
      final width = 1 + rnd.nextInt(2);
      for (var w = -(width ~/ 2); w <= width ~/ 2; w++) {
        final x = (col + w).clamp(0, grid.cols - 1);
        if (_withinRadius(x, row, protectedCells, protectedRadius)) {
          continue;
        }
        grid.setMountain(x, row, true);
        kinds[row][x] = kind;
      }
      col = (col + rnd.nextInt(3) - 1).clamp(2, grid.cols - 3);
    }
  }

  /// Guarantees a path exists from every spawn point to the base, carving a
  /// straight (or L-shaped) corridor through the random scatter if it
  /// sealed one off.
  void _ensureReachable(
    Grid grid,
    List<List<ObstacleKind?>> kinds,
    List<Point<int>> spawnCells,
    Point<int> baseCell,
  ) {
    for (final spawn in spawnCells) {
      if (grid.isReachable(spawn, baseCell)) continue;

      void clearRow(int row) {
        for (var col = 0; col < grid.cols; col++) {
          grid.setMountain(col, row, false);
          kinds[row][col] = null;
        }
      }

      void clearCol(int col, int rowStart, int rowEnd) {
        final from = min(rowStart, rowEnd);
        final to = max(rowStart, rowEnd);
        for (var row = from; row <= to; row++) {
          grid.setMountain(col, row, false);
          kinds[row][col] = null;
        }
      }

      clearRow(spawn.y);
      if (spawn.y != baseCell.y) {
        clearCol(spawn.x, spawn.y, baseCell.y);
      }
    }
  }

  void _scatterHighGround(
    Grid grid,
    List<List<ObstacleKind?>> kinds,
    Random rnd,
    List<Point<int>> protectedCells,
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

          if (_withinRadius(x, y, protectedCells, protectedRadius)) {
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

  bool _withinRadius(int x, int y, List<Point<int>> centers, int radius) {
    for (final center in centers) {
      final dx = x - center.x;
      final dy = y - center.y;
      if (dx * dx + dy * dy <= radius * radius) return true;
    }
    return false;
  }
}
