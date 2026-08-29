import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;

import '../../../core/rendering/procedural_image.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../../map_editor/domain/models/environment_settings.dart';
import '../../map_editor/domain/models/weather_keyframe.dart';
import '../domain/models/terrain_map.dart';
import 'terrain_painter.dart';

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
  double _riverPhase = 0;
  double _treeSwayPhase = 0;
  double _weatherPhase = 0;
  TerrainComponent({required this.terrainMap})
    : super(
        position: Vector2.zero(),
        size: Vector2(terrainMap.arenaWidth, terrainMap.arenaHeight),
        priority: -10,
      );

  /// This scene's match-progress fraction (0..1), used to sample
  /// [EnvironmentSettings.sample] - the same wave-progress fraction the HUD
  /// shows, so a dynamic weather timeline changes pace with the campaign.
  double get _matchProgress {
    final total = game.gameState.totalWaves;
    if (total <= 0) return 0;
    return ((game.gameState.currentWave - 1) / total).clamp(0.0, 1.0);
  }

  @override
  Future<void> onLoad() async {
    _baseImage = await renderToImage(
      size.x.round(),
      size.y.round(),
      _paintBase,
    );
    _riverPath = TerrainPainter.riverPath(terrainMap, size.y);
  }

  @override
  void render(ui.Canvas canvas) {
    // The base image is baked at a supersampled resolution (see
    // renderToImage) purely for source detail - it must always be scaled
    // back down to this component's logical size, never drawn 1:1, or the
    // terrain renders zoomed-in/cropped.
    canvas.drawImageRect(
      _baseImage,
      ui.Rect.fromLTWH(
        0,
        0,
        _baseImage.width.toDouble(),
        _baseImage.height.toDouble(),
      ),
      ui.Rect.fromLTWH(0, 0, size.x, size.y),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );

    final riverPath = _riverPath;
    if (riverPath != null) {
      TerrainPainter.paintRiverFlow(
        canvas,
        riverPath,
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
    final grid = terrainMap.grid;

    for (var row = 0; row < grid.rows; row++) {
      for (var col = 0; col < grid.cols; col++) {
        if (grid.blocked[row][col]) continue;
        final cx = col * grid.cellSize;
        final cy = row * grid.cellSize;
        final rect = ui.Rect.fromLTWH(
          cx + 2,
          cy + 2,
          grid.cellSize - 4,
          grid.cellSize - 4,
        );
        canvas.drawRect(
          rect,
          ui.Paint()
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = (canAfford ? Colors.greenAccent : Colors.redAccent)
                .withValues(alpha: 0.18),
        );
      }
    }
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
    final rect = ui.Rect.fromLTWH(0, 0, size.x, size.y);
    _paintSunLight(canvas, environment, rect);
    _paintWeather(canvas, environment, rect);
  }

  /// Redraws every tree fresh each frame (instead of baking them into
  /// [_baseImage]) so [WeatherKeyframe.windStrength] can make canopies sway.
  void _paintLiveTrees(ui.Canvas canvas) {
    final weather = game.scene.environment.sample(_matchProgress);
    TerrainPainter.paintTrees(
      canvas,
      ui.Size(size.x, size.y),
      terrainMap,
      windStrength: weather.windStrength,
      phase: _treeSwayPhase,
    );
  }

  /// Rain streaks fall straight down, looping back to the top once they
  /// pass the bottom edge - [_weatherPhase] (elapsed seconds) drives the
  /// fall instead of every frame redrawing the same frozen positions.
  /// [WeatherKeyframe.windStrength] still leans each streak's angle. Each
  /// streak gets its own speed/length/width/alpha so the rain reads as a
  /// mix of near/far drops instead of one uniform pattern, and a slight
  /// blur softens the streaks like a wet-glass look.
  void _paintRain(ui.Canvas canvas, WeatherKeyframe weather) {
    final rnd = math.Random(7);
    final lean = weather.windStrength * 10;
    const fallSpeed = 420.0;
    final paint = ui.Paint()
      ..strokeCap = ui.StrokeCap.round
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 0.9);
    for (var i = 0; i < (weather.rainIntensity * 160).round(); i++) {
      final x = rnd.nextDouble() * size.x;
      final baseY = rnd.nextDouble() * size.y;
      final speedMul = 0.7 + rnd.nextDouble() * 0.5;
      final length = 5 + rnd.nextDouble() * 4;
      final y = (baseY + _weatherPhase * fallSpeed * speedMul) % size.y;
      paint
        ..color = Colors.lightBlueAccent.withValues(
          alpha: 0.2 + rnd.nextDouble() * 0.22,
        )
        ..strokeWidth = 0.7 + rnd.nextDouble() * 0.5;
      canvas.drawLine(
        ui.Offset(x, y),
        ui.Offset(x + lean * speedMul, y + length),
        paint,
      );
    }
  }

  /// Snow drifts down slowly with a gentle side-to-side sway (scaled by
  /// [WeatherKeyframe.windStrength]) instead of sitting frozen in place -
  /// same looping-fall approach as [_paintRain], just much slower. Each
  /// flake gets its own size/speed/sway/alpha so the flurry doesn't look
  /// like one repeating stamp.
  void _paintSnow(ui.Canvas canvas, WeatherKeyframe weather) {
    final rnd = math.Random(9);
    const fallSpeed = 60.0;
    for (var i = 0; i < (weather.snowIntensity * 110).round(); i++) {
      final baseX = rnd.nextDouble() * size.x;
      final baseY = rnd.nextDouble() * size.y;
      final driftPhase = rnd.nextDouble() * math.pi * 2;
      final speedMul = 0.6 + rnd.nextDouble() * 0.7;
      final radius = 1.0 + rnd.nextDouble() * 1.4;
      final alpha = 0.45 + rnd.nextDouble() * 0.4;
      final y = (baseY + _weatherPhase * fallSpeed * speedMul) % size.y;
      final sway =
          math.sin(_weatherPhase * (1 + speedMul * 0.4) + driftPhase) *
          (5 + rnd.nextDouble() * 10 + weather.windStrength * 14);
      final x = (baseX + sway) % size.x;
      canvas.drawCircle(
        ui.Offset(x, y),
        radius,
        ui.Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  void _paintSunLight(
    ui.Canvas canvas,
    EnvironmentSettings environment,
    ui.Rect rect,
  ) {
    final sunHeight = math.sin(environment.sunAngle * math.pi).clamp(0.0, 1.0);
    final sunFromRight = math.cos(environment.sunAngle * math.pi) >= 0;
    final warmTint = ui.Color.lerp(
      const ui.Color(0xFFFF8A3D),
      Colors.white,
      sunHeight,
    )!;

    canvas.drawRect(
      rect,
      ui.Paint()
        ..color = const ui.Color(0xFF120A24)
            .withValues(alpha: (1 - sunHeight) * 0.4),
    );

    final from = sunFromRight ? ui.Offset(size.x, 0) : ui.Offset.zero;
    final to = sunFromRight ? ui.Offset.zero : ui.Offset(size.x, 0);
    canvas.drawRect(
      rect,
      ui.Paint()
        ..shader = ui.Gradient.linear(from, to, [
          warmTint.withValues(alpha: 0.12 + (1 - sunHeight) * 0.28),
          Colors.transparent,
        ]),
    );
  }

  void _paintWeather(
    ui.Canvas canvas,
    EnvironmentSettings environment,
    ui.Rect rect,
  ) {
    final weather = environment.sample(_matchProgress);

    _paintWindStreaks(canvas, weather.windStrength);

    if (weather.cloudCover > 0) {
      canvas.drawRect(
        rect,
        ui.Paint()
          ..color = const ui.Color(0xFF37474F)
              .withValues(alpha: weather.cloudCover * 0.35),
      );
    }

    if (weather.fogDensity > 0) {
      canvas.drawRect(
        rect,
        ui.Paint()
          ..shader = ui.Gradient.linear(ui.Offset.zero, ui.Offset(0, size.y), [
            Colors.transparent,
            Colors.white.withValues(alpha: weather.fogDensity * 0.6),
          ]),
      );
    }

    if (weather.rainIntensity > 0) {
      _paintRain(canvas, weather);
    }

    if (weather.snowIntensity > 0) {
      _paintSnow(canvas, weather);
    }
  }

  /// Faint drifting dust/leaf streaks that scale with wind strength - unlike
  /// tree-lean (only visible on tree-bearing biomes), this gives the wind
  /// slider a visible effect on every biome/map.
  void _paintWindStreaks(ui.Canvas canvas, double windStrength) {
    if (windStrength <= 0) return;
    final rnd = math.Random(13);
    final paint = ui.Paint()
      ..color = Colors.white.withValues(alpha: 0.18 * windStrength.clamp(0, 1))
      ..strokeWidth = 1.2
      ..strokeCap = ui.StrokeCap.round;
    final streakLength = 18 + windStrength * 40;
    for (var i = 0; i < (windStrength * 40).round(); i++) {
      final x = rnd.nextDouble() * size.x;
      final y = rnd.nextDouble() * size.y;
      canvas.drawLine(
        ui.Offset(x, y),
        ui.Offset(x + streakLength, y - streakLength * 0.18),
        paint,
      );
    }
  }
}
