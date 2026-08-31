import 'dart:math';
import 'dart:ui' as ui;

import '../../../domain/models/biome.dart';
import '../../../domain/models/obstacle_kind.dart';
import '../../../domain/models/terrain_map.dart';
import '../../../extensions/biome_extensions.dart';
import 'util/chain_biome.dart';
import 'util/connected_cells.dart';
import 'util/obstacle_chains.dart';
import 'util/paint_dune.dart';
import 'util/paint_ground_base.dart';
import 'util/paint_lake.dart';
import 'util/paint_lake_flow_overlay.dart';
import 'util/paint_lava_bed.dart';
import 'util/paint_lava_flow_overlay.dart';
import 'util/paint_mountain.dart';
import 'util/paint_mountain_dune_shadows.dart';
import 'util/paint_river_bed.dart';
import 'util/paint_river_flow_overlay.dart';
import 'util/paint_sea_flow_overlay.dart';
import 'util/paint_trees_overlay.dart';
import 'util/paint_valley_path.dart';
import 'util/paint_volcanic_lake.dart';
import 'util/paint_volcanic_lake_flow_overlay.dart';
import 'util/smooth_path.dart';
import 'util/union_cells_shape.dart';

/// Pure procedural terrain rendering, shared by the in-game [TerrainComponent]
/// (baked once to a full-size cached image) and the level-select biome
/// preview thumbnails (painted small, live, via [CustomPainter]).
class TerrainPainter {
  const TerrainPainter._();

  /// Combined path of every connected blob of [kind] cells in [terrainMap]
  /// (lake or volcanicLake) - null if the map has none. The area-fill
  /// counterpart of [riverPath], used to drive the live [paintLakeFlow]/
  /// [paintVolcanicLakeFlow] overlays.
  static ui.Path? lakeShape(
    TerrainMap terrainMap, {
    ObstacleKind kind = ObstacleKind.lake,
  }) {
    final components = connectedCells(
      terrainMap.grid,
      terrainMap.obstacleKinds,
      kind,
    );
    if (components.isEmpty) return null;
    final combined = ui.Path();
    for (final cells in components) {
      combined.addPath(
        unionCellsShape(cells, terrainMap.grid.cellSize),
        ui.Offset.zero,
      );
    }
    return combined;
  }

  static void paint(ui.Canvas canvas, ui.Size size, TerrainMap terrainMap) {
    final grid = terrainMap.grid;
    final kinds = terrainMap.obstacleKinds;
    final palette = terrainMap.biome.palette;

    paintGroundBase(canvas, size, palette);

    // Rivers/valleys are drawn as one continuous winding ribbon per
    // connected group of cells (instead of independent per-cell tiles) so
    // they read as a real, connected feature rather than a stack of
    // disjoint blocks - this works for any hand-drawn shape (not just a
    // single top-to-bottom crossing), since the ordering is reconstructed
    // from actual cell adjacency rather than assumed. The river's
    // banks/bed are baked here (static); the flowing-water shimmer is
    // drawn live on top every frame instead - see [paintRiverFlow].
    for (final chain in obstacleChains(
      grid,
      kinds,
      ObstacleKind.river,
      size.height,
    )) {
      if (chain.length >= 2) {
        paintRiverBed(
          canvas,
          smoothPath(chain),
          grid.cellSize,
          chainBiome(terrainMap, grid, chain).palette,
        );
      }
    }
    for (final chain in obstacleChains(
      grid,
      kinds,
      ObstacleKind.valley,
      size.height,
    )) {
      if (chain.length >= 2) {
        paintValleyPath(canvas, smoothPath(chain), grid.cellSize);
      }
    }
    // Lakes are area fills (not linear features) - each connected blob of
    // lake cells is unioned into one pond shape instead of ordered into a
    // ribbon.
    for (final component in connectedCells(grid, kinds, ObstacleKind.lake)) {
      paintLake(
        canvas,
        component,
        grid.cellSize,
        terrainMap.biomeAt(component.first.x, component.first.y).palette,
      );
    }

    // Lava/volcanic lakes are the molten counterparts of river/lake - a
    // fixed magma look regardless of biome, since molten rock doesn't get
    // a biome tint the way water/sand does.
    for (final chain in obstacleChains(
      grid,
      kinds,
      ObstacleKind.lava,
      size.height,
    )) {
      if (chain.length >= 2) {
        paintLavaBed(canvas, smoothPath(chain), grid.cellSize);
      }
    }
    for (final component in connectedCells(
      grid,
      kinds,
      ObstacleKind.volcanicLake,
    )) {
      paintVolcanicLake(canvas, component, grid.cellSize);
    }

    // Pseudo-3D contact shadow pass: every mountain/dune cell drops a soft
    // dark shadow offset down-right (fake sun direction) before the shape
    // itself is painted, giving the ridge/dune a sense of elevation.
    paintMountainDuneShadows(canvas, grid, kinds);

    for (var row = 0; row < grid.rows; row++) {
      for (var col = 0; col < grid.cols; col++) {
        switch (kinds[row][col]) {
          case ObstacleKind.mountain:
            paintMountain(
              canvas,
              grid,
              col,
              row,
              terrainMap.biomeAt(col, row).palette,
            );
          case ObstacleKind.dune:
            paintDune(
              canvas,
              grid,
              col,
              row,
              terrainMap.biomeAt(col, row).palette,
            );
          case ObstacleKind.river:
          case ObstacleKind.valley:
          case ObstacleKind.lake:
          case ObstacleKind.lava:
          case ObstacleKind.volcanicLake:
            break; // already painted as a continuous ribbon/pond above
          case null:
            break; // open ground - trees are drawn live, see [paintTrees]
        }
      }
    }
  }

  /// Live per-frame glassy shimmer for still water (lakes): soft blurred
  /// glints drift slowly across the surface and gentle ripple rings expand
  /// and fade - the stillwater counterpart to [paintRiverFlow]'s
  /// directional flow, clipped to [shape] so nothing bleeds past the
  /// shoreline.
  static void paintLakeFlow(
    ui.Canvas canvas,
    ui.Path shape,
    double cellSize,
    double phase,
  ) => paintLakeFlowOverlay(canvas, shape, cellSize, phase);

  /// Live per-frame animated overlay for a lava ribbon: a pulsing bright
  /// glow (brightness oscillates with [phase]) plus drifting ember specks,
  /// on top of the static [paintLavaBed].
  static void paintLavaFlow(
    ui.Canvas canvas,
    ui.Path path,
    double cellSize,
    double phase,
  ) => paintLavaFlowOverlay(canvas, path, cellSize, phase);

  /// Live per-frame animated overlay for a river: soft, blurred glassy
  /// highlight bands ripple along the flow (a translucent, softly-lit
  /// glassy "wave" look, rather than crisp dashes) plus gentle shimmering
  /// glints and expanding ripple rings - all drift downstream as [phase]
  /// (elapsed seconds) advances, on top of the static [paintRiverBed].
  static void paintRiverFlow(
    ui.Canvas canvas,
    ui.Path path,
    double cellSize,
    double phase,
  ) => paintRiverFlowOverlay(canvas, path, cellSize, phase);

  /// Live per-frame open-ocean wave overlay for the "sea" biome's main
  /// water body (as opposed to a contained pond): several long,
  /// sine-wavy wave crests roll across the whole sea, plus scattered
  /// shimmering glints and gentle expanding ripples - the same
  /// glassy-shimmer vocabulary as [paintLakeFlow], scaled up and clipped
  /// to [shape] (the arena minus any reef/islet land) instead of a single
  /// pond, so open water finally reads as moving rather than a flat
  /// static tint.
  static void paintSeaFlow(
    ui.Canvas canvas,
    ui.Path shape,
    double cellSize,
    double phase,
  ) => paintSeaFlowOverlay(canvas, shape, cellSize, phase);

  /// Live per-frame companion to [paint] (which never draws trees itself)
  /// - redrawn every frame so each canopy's [treeSway] offset can respond
  /// to [windStrength] as [phase] (elapsed seconds) advances, instead of
  /// standing perfectly still. Only draws [TerrainMap.treeCells] - a
  /// biome never automatically sprouts trees the map's own data doesn't
  /// have; procedurally generated scenes bake their forest cover into
  /// [TerrainMap.treeCells] once at generation time (see
  /// `TerrainRepositoryImpl._scatterTrees`), and map-editor-authored maps
  /// rely solely on their own Tree brush placements.
  static void paintTrees(
    ui.Canvas canvas,
    ui.Size size,
    TerrainMap terrainMap, {
    double windStrength = 0,
    double phase = 0,
  }) => paintTreesOverlay(
    canvas,
    size,
    terrainMap,
    windStrength: windStrength,
    phase: phase,
  );

  /// Live per-frame magma shimmer for volcanic lakes: a pulsing ambient
  /// glow plus rising, fading embers, clipped to [shape] - the pond
  /// counterpart to [paintLavaFlow].
  static void paintVolcanicLakeFlow(
    ui.Canvas canvas,
    ui.Path shape,
    double cellSize,
    double phase,
  ) => paintVolcanicLakeFlowOverlay(canvas, shape, cellSize, phase);

  /// Combined path of every river segment in [terrainMap] (one subpath per
  /// connected group of river cells), smoothed - null if this map has no
  /// river (e.g. desert biome, which uses a dry valley instead). Used both
  /// to bake the static bed (see [paintRiverBed]) and to drive the live
  /// [paintRiverFlow] overlay. Pass `kind: ObstacleKind.lava` to get the
  /// equivalent path for lava ribbons instead.
  static ui.Path? riverPath(
    TerrainMap terrainMap,
    double canvasHeight, {
    ObstacleKind kind = ObstacleKind.river,
  }) {
    final chains = obstacleChains(
      terrainMap.grid,
      terrainMap.obstacleKinds,
      kind,
      canvasHeight,
    );
    final combined = ui.Path();
    var hasAny = false;
    for (final chain in chains) {
      if (chain.length < 2) continue;
      combined.addPath(smoothPath(chain), ui.Offset.zero);
      hasAny = true;
    }
    return hasAny ? combined : null;
  }

  /// The arena rect minus every mountain/dune (reef/islet) cell - the
  /// clip shape for [paintSeaFlow] so the open-ocean wave overlay never
  /// paints across land, null for non-[Biome.sea] maps (or a sea map with
  /// no reefs, in which case the whole arena is water).
  static ui.Path? seaWaterShape(TerrainMap terrainMap) {
    if (terrainMap.biome != Biome.sea) return null;
    final full = ui.Path()
      ..addRect(
        ui.Rect.fromLTWH(0, 0, terrainMap.arenaWidth, terrainMap.arenaHeight),
      );
    final grid = terrainMap.grid;
    final kinds = terrainMap.obstacleKinds;
    final landCells = <Point<int>>[];
    for (var row = 0; row < grid.rows; row++) {
      for (var col = 0; col < grid.cols; col++) {
        final kind = kinds[row][col];
        if (kind == ObstacleKind.mountain || kind == ObstacleKind.dune) {
          landCells.add(Point(col, row));
        }
      }
    }
    if (landCells.isEmpty) return full;
    final landShape = unionCellsShape(landCells, grid.cellSize);
    return ui.Path.combine(ui.PathOperation.difference, full, landShape);
  }
}
