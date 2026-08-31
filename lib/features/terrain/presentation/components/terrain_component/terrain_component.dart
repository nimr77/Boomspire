import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../../../../../core/rendering/procedural_image.dart';
import '../../../../game_core/presentation/boomspire_game.dart';
import '../../../domain/models/obstacle_kind.dart';
import '../../../domain/models/terrain_map.dart';
import '../terrain_painter/terrain_painter.dart';
import 'util/paint_base_image.dart';
import 'util/paint_buildable_grid_overlay.dart';
import 'util/paint_sun_light.dart';
import 'util/paint_weather_overlay.dart';

/// Paints the terrain once to a cached image: a biome-flavored ground with
/// scattered high-ground obstacles (mountains/dunes) and a winding
/// river/valley crossing (also used as pathfinding obstacles). A thin
/// dynamic overlay highlights the buildable cell under the cursor/selection
/// while in build mode. Rivers additionally get a lightweight animated
/// overlay (see [_riverPath]/[_riverPhase]) drawn live on top of the cached
/// image so the water visibly flows instead of looking like a static ribbon.
class TerrainComponent extends PositionComponent
    with HasGameReference<BoomspireGame> {
  final TerrainMap terrainMap;

  late final ui.Image _baseImage;
  ui.Path? _riverPath;
  ui.Path? _lavaPath;
  ui.Path? _lakeShape;
  ui.Path? _volcanicLakeShape;
  ui.Path? _seaWaterShape;
  double _riverPhase = 0;
  double _treeSwayPhase = 0;
  double _weatherPhase = 0;
  TerrainComponent({required this.terrainMap})
    : super(
        position: Vector2.zero(),
        size: Vector2(terrainMap.arenaWidth, terrainMap.arenaHeight),
        priority: -10,
      );

  @override
  Future<void> onLoad() async {
    _baseImage = await renderToImage(
      size.x.round(),
      size.y.round(),
      _paintBase,
    );
    _riverPath = TerrainPainter.riverPath(terrainMap, size.y);
    _lavaPath = TerrainPainter.riverPath(
      terrainMap,
      size.y,
      kind: ObstacleKind.lava,
    );
    _lakeShape = TerrainPainter.lakeShape(terrainMap);
    _volcanicLakeShape = TerrainPainter.lakeShape(
      terrainMap,
      kind: ObstacleKind.volcanicLake,
    );
    _seaWaterShape = TerrainPainter.seaWaterShape(terrainMap);
  }

  @override
  void render(ui.Canvas canvas) {
    // The base image is baked at a supersampled resolution (see
    // renderToImage) purely for source detail - it must always be scaled
    // back down to this component's logical size, never drawn 1:1, or the
    // terrain renders zoomed-in/cropped.
    paintBaseImage(canvas, _baseImage, width: size.x, height: size.y);

    final riverPath = _riverPath;
    if (riverPath != null) {
      TerrainPainter.paintRiverFlow(
        canvas,
        riverPath,
        terrainMap.grid.cellSize,
        _riverPhase,
      );
    }
    final lavaPath = _lavaPath;
    if (lavaPath != null) {
      TerrainPainter.paintLavaFlow(
        canvas,
        lavaPath,
        terrainMap.grid.cellSize,
        _riverPhase,
      );
    }
    final lakeShape = _lakeShape;
    if (lakeShape != null) {
      TerrainPainter.paintLakeFlow(
        canvas,
        lakeShape,
        terrainMap.grid.cellSize,
        _riverPhase,
      );
    }
    final volcanicLakeShape = _volcanicLakeShape;
    if (volcanicLakeShape != null) {
      TerrainPainter.paintVolcanicLakeFlow(
        canvas,
        volcanicLakeShape,
        terrainMap.grid.cellSize,
        _riverPhase,
      );
    }
    final seaWaterShape = _seaWaterShape;
    if (seaWaterShape != null) {
      TerrainPainter.paintSeaFlow(
        canvas,
        seaWaterShape,
        terrainMap.grid.cellSize,
        _riverPhase,
      );
    }

    _paintLiveTrees(canvas);
    _paintEnvironment(canvas);

    final selected = game.selectedTowerType.value;
    if (selected == null) return;
    final blueprint = game.blueprintFor(selected);
    final canAfford = game.gameState.gold >= blueprint.cost;
    paintBuildableGridOverlay(canvas, terrainMap.grid, canAfford: canAfford);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _riverPhase += dt;
    _treeSwayPhase += dt;
    _weatherPhase += dt;
  }

  void _paintBase(ui.Canvas canvas) {
    // Trees are never baked by [TerrainPainter.paint] - they're painted
    // live every frame instead (see [_paintLiveTrees]) so their canopies
    // can sway with wind rather than standing frozen in a static image.
    TerrainPainter.paint(canvas, ui.Size(size.x, size.y), terrainMap);
  }

  /// Renders the scene's authored sun/weather look live (see
  /// `MapEditorCanvasPainter`, which this mirrors) - drawn fresh every frame
  /// rather than baked into [_baseImage] since dynamic weather changes over
  /// the course of a match.
  void _paintEnvironment(ui.Canvas canvas) {
    final environment = game.scene.environment;
    final weather = environment.sampleBlend(game.weatherFocus.weights);
    final resolvedType = weather.resolvedWindType(game.scene.biome);
    paintSunLight(canvas, environment.sunAngle, width: size.x, height: size.y);
    paintWeatherOverlay(
      canvas,
      weather,
      resolvedType,
      width: size.x,
      height: size.y,
      weatherPhase: _weatherPhase,
    );
  }

  /// Redraws every tree fresh each frame (instead of baking them into
  /// [_baseImage]) so weather's wind strength can make canopies sway.
  void _paintLiveTrees(ui.Canvas canvas) {
    final weather = game.scene.environment.sampleBlend(
      game.weatherFocus.weights,
    );
    TerrainPainter.paintTrees(
      canvas,
      ui.Size(size.x, size.y),
      terrainMap,
      windStrength: weather.windStrength,
      phase: _treeSwayPhase,
    );
  }
}
