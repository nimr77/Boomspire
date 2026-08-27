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

    final baseCell =
        scene.mode == GameMode.skirmish && scene.homeSites.isNotEmpty
        ? _baseCell(
            _homeSiteFor(scene, HomeSiteOwner.player).layout,
            cols,
            rows,
          )
        : _baseCell(scene.homeLayout, cols, rows);

    // A skirmish scene's "spawn" is the AI opponent's base - every unit that
    // marches toward the player's base starts from there, and the same
    // "every declared entry point can still reach the base" check the
    // player's build menu already runs (see `BoomspireGame._buildTower`)
    // then doubles as "never let either side wall the other completely
    // out". Only one AI seat is supported today (see [GameScenes.skirmishes]'
    // doc comment) - additional `ai` seats are ignored for now.
    final secondaryBaseCell =
        scene.mode == GameMode.skirmish && scene.homeSites.isNotEmpty
        ? _baseCell(_homeSiteFor(scene, HomeSiteOwner.ai).layout, cols, rows)
        : null;

    final spawnCells = secondaryBaseCell != null
        ? [secondaryBaseCell]
        : _spawnCells(baseCell, cols, rows);
    final nodeCells = _resourceNodeCells(scene.resourceNodeSites, cols, rows);
    final protectedCells = [baseCell, ...spawnCells, ...nodeCells];
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
    _ensureReachable(grid, obstacleKinds, [
      ...spawnCells,
      ...nodeCells,
    ], baseCell);

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
      secondaryBasePoint: secondaryBaseCell == null
          ? null
          : PathPoint(
              grid.cellCenter(secondaryBaseCell).x,
              grid.cellCenter(secondaryBaseCell).y,
            ),
      resourceNodePoints: nodeCells
          .map((c) => PathPoint(grid.cellCenter(c).x, grid.cellCenter(c).y))
          .toList(),
    );
  }

  Point<int> _baseCell(HomeLayout layout, int cols, int rows) =>
      switch (layout) {
        HomeLayout.eastEdge => Point(cols - 1, rows ~/ 2),
        HomeLayout.center => Point(cols ~/ 2, rows ~/ 2),
        HomeLayout.northEastCorner => Point(cols - 2, 1),
        HomeLayout.southWestCorner => Point(1, rows - 2),
      };

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

  int _distSq(Point<int> a, Point<int> b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return dx * dx + dy * dy;
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

  /// The (first) [HomeSite] claimed by [owner] on a skirmish scene, falling
  /// back to whichever site is first/last if none is explicitly tagged that
  /// way - keeps terrain generation resilient even if a future scene ever
  /// omits an owner.
  HomeSite _homeSiteFor(GameScene scene, HomeSiteOwner owner) {
    for (final site in scene.homeSites) {
      if (site.owner == owner) return site;
    }
    return owner == HomeSiteOwner.player
        ? scene.homeSites.first
        : scene.homeSites.last;
  }

  /// Converts each scene-relative [ResourceNodeSite] fraction into a grid
  /// cell, clamped inside the playable area so nodes never land on the
  /// unreachable border.
  List<Point<int>> _resourceNodeCells(
    List<ResourceNodeSite> sites,
    int cols,
    int rows,
  ) => sites
      .map(
        (site) => Point(
          (site.dx * cols).round().clamp(1, cols - 2),
          (site.dy * rows).round().clamp(1, rows - 2),
        ),
      )
      .toList();

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

  /// Perimeter approach points all the way around the arena (edges +
  /// corners), excluding the base itself. The AI director spawns from a
  /// random one of these per enemy (see `EnemyComponent.onLoad`) - attacks
  /// are never telegraphed from a single fixed "incoming direction", they
  /// can come from anywhere around the map regardless of [layout].
  List<Point<int>> _spawnCells(Point<int> base, int cols, int rows) {
    final candidates = <Point<int>>[
      Point(0, rows ~/ 2), // west
      Point(cols - 1, rows ~/ 2), // east
      Point(cols ~/ 2, 0), // north
      Point(cols ~/ 2, rows - 1), // south
      Point(0, 0), // northwest
      Point(cols - 1, 0), // northeast
      Point(0, rows - 1), // southwest
      Point(cols - 1, rows - 1), // southeast
    ]..removeWhere((p) => p == base);

    candidates.sort((a, b) => _distSq(b, base).compareTo(_distSq(a, base)));
    return candidates;
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
