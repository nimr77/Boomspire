import 'dart:math';
import 'dart:ui' as ui;

import '../../../../domain/models/terrain_map.dart';
import 'paint_tree.dart';
import 'tree_sway.dart';

/// Live per-frame companion to `TerrainPainter.paint` (which never draws
/// trees itself) - redrawn every frame so each canopy's `treeSway` offset
/// can respond to [windStrength] as [phase] (elapsed seconds) advances,
/// instead of standing perfectly still. Only draws [TerrainMap.treeCells]
/// - a biome never automatically sprouts trees the map's own data doesn't
/// have; procedurally generated scenes bake their forest cover into
/// [TerrainMap.treeCells] once at generation time (see
/// `TerrainRepositoryImpl._scatterTrees`), and map-editor-authored maps
/// rely solely on their own Tree brush placements.
void paintTreesOverlay(
  ui.Canvas canvas,
  ui.Size size,
  TerrainMap terrainMap, {
  double windStrength = 0,
  double phase = 0,
}) {
  if (terrainMap.treeCells.isEmpty) return;
  final grid = terrainMap.grid;
  final kinds = terrainMap.obstacleKinds;

  // Fresh, dedicated seed every call so scatter jitter/scale stay fixed
  // across frames; only the sway offset (driven by [phase], not this
  // RNG) actually animates.
  final rnd = Random(1337);
  for (final tree in terrainMap.treeCells) {
    if (tree.y < 0 || tree.y >= grid.rows) continue;
    if (tree.x < 0 || tree.x >= grid.cols) continue;
    if (kinds[tree.y][tree.x] != null) continue;
    paintTree(
      canvas,
      grid,
      tree.x,
      tree.y,
      rnd,
      terrainMap.biomeAt(tree.x, tree.y),
      sway: treeSway(
        col: tree.x,
        row: tree.y,
        windStrength: windStrength,
        phase: phase,
      ),
    );
  }
}
