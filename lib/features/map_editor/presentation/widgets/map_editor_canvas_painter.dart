import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../game_core/presentation/home_site_marker_painter.dart';
import '../../../terrain/domain/models/biome.dart';
import '../../../terrain/extensions/biome_extensions.dart';
import '../../../terrain/presentation/obstacle_color.dart';
import '../../domain/models/editor_point.dart';
import '../../domain/models/editor_terrain_preview.dart';
import '../../domain/models/environment_settings.dart';
import '../../domain/models/tree_cell.dart';
import '../state/map_editor_draft_state.dart';

/// Renders the map editor canvas: the rasterized terrain grid, sun/weather
/// overlays, numbered home-site markers, and the in-progress river/lake
/// stroke.
class MapEditorCanvasPainter extends CustomPainter {
  final EditorTerrainPreview? preview;
  final List<EditorPoint> activeStroke;
  final EditorTool tool;
  final double arenaWidth;
  final double arenaHeight;
  final EnvironmentSettings environment;
  final double previewProgress;
  final List<EditorPoint> homeSites;
  final List<TreeCell> treeCells;

  MapEditorCanvasPainter({
    required this.preview,
    required this.activeStroke,
    required this.tool,
    required this.arenaWidth,
    required this.arenaHeight,
    required this.environment,
    required this.previewProgress,
    required this.homeSites,
    required this.treeCells,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final palette = (preview?.biome ?? Biome.grassPlains).palette;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, size.height),
          [palette.groundTop, palette.groundMid, palette.groundBottom],
          const [0.0, 0.5, 1.0],
        ),
    );

    final p = preview;
    if (p != null && p.grid.cols > 0 && p.grid.rows > 0) {
      final cellW = size.width / p.grid.cols;
      final cellH = size.height / p.grid.rows;
      for (var row = 0; row < p.grid.rows; row++) {
        for (var col = 0; col < p.grid.cols; col++) {
          final kind = p.obstacleKinds[row][col];
          if (kind == null) continue;
          final cellPalette = (p.variants[row][col] ?? p.biome).palette;
          canvas.drawRect(
            Rect.fromLTWH(col * cellW, row * cellH, cellW, cellH),
            Paint()..color = obstacleColor(kind, cellPalette),
          );
        }
      }
      final gridPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..strokeWidth = 1;
      for (var col = 0; col <= p.grid.cols; col++) {
        canvas.drawLine(
          Offset(col * cellW, 0),
          Offset(col * cellW, size.height),
          gridPaint,
        );
      }
      for (var row = 0; row <= p.grid.rows; row++) {
        canvas.drawLine(
          Offset(0, row * cellH),
          Offset(size.width, row * cellH),
          gridPaint,
        );
      }
      _paintTrees(canvas, p, cellW, cellH);
    }

    _paintSunLight(canvas, rect, size);
    _paintWeather(canvas, rect, size);
    _paintHomeSites(canvas, size);

    if (activeStroke.length >= 2) {
      final path = Path()
        ..moveTo(
          activeStroke[0].x / arenaWidth * size.width,
          activeStroke[0].y / arenaHeight * size.height,
        );
      for (final point in activeStroke.skip(1)) {
        path.lineTo(
          point.x / arenaWidth * size.width,
          point.y / arenaHeight * size.height,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color =
              (tool == EditorTool.lake
                      ? Colors.blueAccent
                      : Colors.lightBlueAccent)
                  .withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MapEditorCanvasPainter oldDelegate) {
    return oldDelegate.preview != preview ||
        oldDelegate.activeStroke != activeStroke ||
        oldDelegate.tool != tool ||
        oldDelegate.arenaWidth != arenaWidth ||
        oldDelegate.arenaHeight != arenaHeight ||
        oldDelegate.environment != environment ||
        oldDelegate.previewProgress != previewProgress ||
        oldDelegate.homeSites != homeSites ||
        oldDelegate.treeCells != treeCells;
  }

  /// Draws each skirmish home site as a numbered, colored marker so a map
  /// author can see at a glance which player seat sits where - the same
  /// numbering/coloring the pre-game placement screen will use.
  void _paintHomeSites(Canvas canvas, Size size) {
    for (final (index, site) in homeSites.indexed) {
      final center = Offset(
        site.x / arenaWidth * size.width,
        site.y / arenaHeight * size.height,
      );
      paintHomeSiteMarker(canvas, center, index);
    }
  }

  /// Tints/dims the scene by sun height and adds raking light from whichever
  /// side the sun sits on - low angles (sunrise/sunset) look warm and
  /// high-contrast, overhead sun looks bright and neutral.
  void _paintSunLight(Canvas canvas, Rect rect, Size size) {
    final sunHeight = sin(environment.sunAngle * pi).clamp(0.0, 1.0);
    final sunFromRight = cos(environment.sunAngle * pi) >= 0;
    final warmTint = Color.lerp(
      const Color(0xFFFF8A3D),
      Colors.white,
      sunHeight,
    )!;

    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFF120A24)
            .withValues(alpha: (1 - sunHeight) * 0.4),
    );

    final from = sunFromRight ? Offset(size.width, 0) : Offset.zero;
    final to = sunFromRight ? Offset.zero : Offset(size.width, 0);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(from, to, [
          warmTint.withValues(alpha: 0.12 + (1 - sunHeight) * 0.28),
          Colors.transparent,
        ]),
    );
  }

  /// Dispatches to a per-biome canopy shape (mirrors `TerrainPainter._paintTree`'s
  /// 8-biome styles, simplified/rescaled for this marker's tiny footprint)
  /// so the editor preview actually shows what each biome's trees will look
  /// like in-game, instead of one generic green blob everywhere.
  void _paintTreeMarker(
    Canvas canvas,
    Offset center,
    double cellSize,
    double windStrength,
    Biome biome,
  ) {
    final lean = windStrength * cellSize * 0.22;
    final trunkBottom = Offset(center.dx, center.dy + cellSize * 0.28);
    final canopyCenter = Offset(center.dx + lean, center.dy - cellSize * 0.05);
    final r = cellSize * 0.22;

    void trunk(int color) {
      canvas.drawLine(
        trunkBottom,
        Offset(canopyCenter.dx, canopyCenter.dy + cellSize * 0.1),
        Paint()
          ..color = Color(color)
          ..strokeWidth = cellSize * 0.06,
      );
    }

    switch (biome) {
      case Biome.mountainForest:
        trunk(0xFF4a3421);
        canvas.drawCircle(
          canopyCenter.translate(-r * 0.4, 0),
          r * 0.8,
          Paint()..color = const Color(0xFF14311a).withValues(alpha: 0.94),
        );
        canvas.drawCircle(
          canopyCenter.translate(r * 0.4, r * 0.15),
          r * 0.85,
          Paint()..color = const Color(0xFF14311a).withValues(alpha: 0.94),
        );
      case Biome.savanna:
        trunk(0xFF5a3f1f);
        canvas.drawOval(
          Rect.fromCenter(
            center: canopyCenter,
            width: r * 2.4,
            height: r * 0.9,
          ),
          Paint()..color = const Color(0xFF6b7a3d).withValues(alpha: 0.92),
        );
      case Biome.snowTundra:
        trunk(0xFF4a3421);
        canvas.drawCircle(
          canopyCenter,
          r,
          Paint()..color = const Color(0xFF1f3d22).withValues(alpha: 0.92),
        );
        canvas.drawArc(
          Rect.fromCenter(center: canopyCenter, width: r * 2, height: r * 1.6),
          pi,
          pi,
          false,
          Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.8),
        );
      case Biome.frozenPeaks:
        trunk(0xFF3a3228);
        final path = Path()
          ..moveTo(canopyCenter.dx - r, canopyCenter.dy + r * 0.5)
          ..lineTo(canopyCenter.dx, canopyCenter.dy - r)
          ..lineTo(canopyCenter.dx + r, canopyCenter.dy + r * 0.5)
          ..close();
        canvas.drawPath(
          path,
          Paint()..color = const Color(0xFF375a52).withValues(alpha: 0.9),
        );
        canvas.drawCircle(
          Offset(canopyCenter.dx, canopyCenter.dy - r * 0.7),
          r * 0.28,
          Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.85),
        );
      case Biome.desertDunes:
        final paint = Paint()
          ..color = const Color(0xFF7a5c3d)
          ..style = PaintingStyle.stroke
          ..strokeWidth = cellSize * 0.05
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(trunkBottom, canopyCenter, paint);
        for (final branch in [
          canopyCenter.translate(-r * 0.9, -r * 0.7),
          canopyCenter.translate(r * 0.8, -r * 0.6),
          canopyCenter.translate(-r * 0.2, -r),
        ]) {
          canvas.drawLine(canopyCenter, branch, paint);
        }
      case Biome.sea:
        canvas.drawLine(
          trunkBottom,
          canopyCenter,
          Paint()
            ..color = const Color(0xFF8a6a3f)
            ..strokeWidth = cellSize * 0.06,
        );
        final frondPaint = Paint()
          ..color = const Color(0xFF2f7a4a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = cellSize * 0.05
          ..strokeCap = StrokeCap.round;
        for (final angle in [-1.1, -0.3, 0.5]) {
          canvas.drawLine(
            canopyCenter,
            canopyCenter.translate(cos(angle) * r, sin(angle) * r - r * 0.3),
            frondPaint,
          );
        }
      case Biome.cityRuins:
        final paint = Paint()
          ..color = const Color(0xFF2a2622)
          ..style = PaintingStyle.stroke
          ..strokeWidth = cellSize * 0.05
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(trunkBottom, canopyCenter, paint);
        for (final branch in [
          canopyCenter.translate(-r * 0.9, -r * 0.5),
          canopyCenter.translate(r * 0.7, -r * 0.8),
          canopyCenter.translate(r * 0.1, -r),
        ]) {
          canvas.drawLine(canopyCenter, branch, paint);
        }
      case Biome.grassPlains:
        trunk(0xFF4a3421);
        canvas.drawCircle(
          canopyCenter,
          r,
          Paint()..color = const Color(0xFF1f3d22).withValues(alpha: 0.9),
        );
    }
  }

  /// Draws every hand-placed [treeCells] marker - a biome never grows
  /// trees an author didn't place with the Tree brush; this preview only
  /// ever shows what the map's own data actually contains, so it matches
  /// `TerrainPainter`/real gameplay exactly. Tree style is keyed off the
  /// map's own biome (matching `TerrainPainter`, which does the same -
  /// trees don't carry a per-cell brush-type override).
  void _paintTrees(
    Canvas canvas,
    EditorTerrainPreview p,
    double cellW,
    double cellH,
  ) {
    final windStrength = environment.sample(previewProgress).windStrength;
    final biome = p.biome;

    for (final tree in treeCells) {
      if (tree.row < 0 || tree.row >= p.grid.rows) continue;
      if (tree.col < 0 || tree.col >= p.grid.cols) continue;
      if (p.obstacleKinds[tree.row][tree.col] != null) continue;
      final center = Offset(
        tree.col * cellW + cellW / 2,
        tree.row * cellH + cellH / 2,
      );
      _paintTreeMarker(canvas, center, min(cellW, cellH), windStrength, biome);
    }
  }

  /// Samples the weather timeline at [previewProgress] and draws cloud/fog
  /// tinting plus simple rain/snow overlays so timeline edits are visible.
  void _paintWeather(Canvas canvas, Rect rect, Size size) {
    final weather = environment.sample(previewProgress);

    _paintWindStreaks(canvas, size, weather.windStrength);

    if (weather.cloudCover > 0) {
      canvas.drawRect(
        rect,
        Paint()
          ..color = const Color(0xFF37474F)
              .withValues(alpha: weather.cloudCover * 0.35),
      );
    }

    if (weather.fogDensity > 0) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [
            Colors.transparent,
            Colors.white.withValues(alpha: weather.fogDensity * 0.6),
          ]),
      );
    }

    if (weather.rainIntensity > 0) {
      final rnd = Random(7);
      final lean = weather.windStrength * 16;
      final paint = Paint()
        ..color = Colors.lightBlueAccent.withValues(alpha: 0.4)
        ..strokeWidth = 1.4;
      for (var i = 0; i < (weather.rainIntensity * 160).round(); i++) {
        final x = rnd.nextDouble() * size.width;
        final y = rnd.nextDouble() * size.height;
        canvas.drawLine(Offset(x, y), Offset(x + lean, y + 14), paint);
      }
    }

    if (weather.snowIntensity > 0) {
      final rnd = Random(9);
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);
      for (var i = 0; i < (weather.snowIntensity * 110).round(); i++) {
        final x = rnd.nextDouble() * size.width;
        final y = rnd.nextDouble() * size.height;
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  /// Faint drifting dust/leaf streaks that scale with wind strength - unlike
  /// tree-lean (only visible on tree-bearing biomes), this makes the wind
  /// slider have a visible effect on every biome/map.
  void _paintWindStreaks(Canvas canvas, Size size, double windStrength) {
    if (windStrength <= 0) return;
    final rnd = Random(13);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18 * windStrength.clamp(0, 1))
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final streakLength = 18 + windStrength * 40;
    for (var i = 0; i < (windStrength * 40).round(); i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + streakLength, y - streakLength * 0.18),
        paint,
      );
    }
  }
}
