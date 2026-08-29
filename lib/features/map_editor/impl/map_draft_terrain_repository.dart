import 'dart:math';

import '../../../core/pathfinding/grid.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../terrain/domain/models/obstacle_kind.dart';
import '../../terrain/domain/models/terrain_map.dart';
import '../../terrain/domain/repos/terrain_repository.dart';
import '../domain/models/editor_point.dart';
import '../domain/models/editor_terrain_preview.dart';
import '../domain/models/map_draft.dart';

/// Turns an editor-authored [MapDraft] into a real, playable [TerrainMap] so
/// it can be test-played through the normal [GamePage] - reuses the
/// draft's already-rasterized [EditorTerrainPreview] rather than the
/// procedural generation [TerrainRepository]'s default impl does.
///
/// Home/spawn placement defaults to a fixed base on the east edge and a
/// single spawn from the west, but [humanBaseSite] (chosen on the pre-game
/// placement screen) overrides the base cell when provided. When [aiBaseSite]
/// is also provided (a real skirmish match, not just a quick single-base test
/// play), it becomes the second, AI-owned base instead of that default single
/// spawn point. Every carved cell (and a guaranteed path between whichever
/// two matter) is cleared of any painted obstacles so a test play is always
/// winnable.
class MapDraftTerrainRepository implements TerrainRepository {
  final MapDraft draft;
  final EditorTerrainPreview preview;
  final EditorPoint? humanBaseSite;
  final EditorPoint? aiBaseSite;

  MapDraftTerrainRepository({
    required this.draft,
    required this.preview,
    this.humanBaseSite,
    this.aiBaseSite,
  });

  @override
  TerrainMap loadTerrain({required GameScene scene}) {
    final grid = preview.grid;
    final obstacleKinds = preview.obstacleKinds;
    Point<int> cellFor(EditorPoint site) => Point(
      (site.x / draft.arenaWidth * grid.cols).floor().clamp(0, grid.cols - 1),
      (site.y / draft.arenaHeight * grid.rows).floor().clamp(0, grid.rows - 1),
    );

    final site = humanBaseSite;
    final baseCell = site != null
        ? cellFor(site)
        : Point(grid.cols - 1, grid.rows ~/ 2);
    final aiSite = aiBaseSite;
    final secondaryBaseCell = aiSite != null ? cellFor(aiSite) : null;
    final spawnCell = secondaryBaseCell ?? Point(0, grid.rows ~/ 2);

    void clearCell(Point<int> cell) {
      grid.setMountain(cell.x, cell.y, false);
      obstacleKinds[cell.y][cell.x] = null;
    }

    clearCell(baseCell);
    clearCell(spawnCell);
    _ensureReachable(grid, obstacleKinds, spawnCell, baseCell);

    return TerrainMap(
      arenaWidth: draft.arenaWidth,
      arenaHeight: draft.arenaHeight,
      grid: grid,
      biome: draft.biome,
      obstacleKinds: obstacleKinds,
      spawnPoints: [
        PathPoint(grid.cellCenter(spawnCell).x, grid.cellCenter(spawnCell).y),
      ],
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
      treeCells: [
        for (final tree in draft.treeCells)
          if (Point(tree.col, tree.row) != baseCell &&
              Point(tree.col, tree.row) != spawnCell &&
              Point(tree.col, tree.row) != secondaryBaseCell)
            Point(tree.col, tree.row),
      ],
      variants: preview.variants,
    );
  }

  /// Carves a straight clear corridor between spawn and base if the
  /// player's painted obstacles sealed one off.
  void _ensureReachable(
    Grid grid,
    List<List<ObstacleKind?>> kinds,
    Point<int> spawn,
    Point<int> base,
  ) {
    if (grid.isReachable(spawn, base)) return;

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
    if (spawn.y != base.y) clearCol(spawn.x, spawn.y, base.y);
  }
}
