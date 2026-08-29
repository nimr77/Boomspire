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

  MapEditorCanvasPainter({
    required this.preview,
    required this.activeStroke,
    required this.tool,
    required this.arenaWidth,
    required this.arenaHeight,
    required this.environment,
    required this.previewProgress,
    required this.homeSites,
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
          canvas.drawRect(
            Rect.fromLTWH(col * cellW, row * cellH, cellW, cellH),
            Paint()..color = obstacleColor(kind, palette),
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
      _paintTrees(canvas, p, palette, cellW, cellH);
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
        oldDelegate.homeSites != homeSites;
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

  void _paintTreeMarker(
    Canvas canvas,
    Offset center,
    double cellSize,
    double windStrength,
  ) {
    final lean = windStrength * cellSize * 0.22;
    final trunkBottom = Offset(center.dx, center.dy + cellSize * 0.28);
    final canopyCenter = Offset(center.dx + lean, center.dy - cellSize * 0.05);
    canvas.drawLine(
      trunkBottom,
      Offset(canopyCenter.dx, canopyCenter.dy + cellSize * 0.1),
      Paint()
        ..color = const Color(0xFF4a3421)
        ..strokeWidth = cellSize * 0.06,
    );
    canvas.drawCircle(
      canopyCenter,
      cellSize * 0.22,
      Paint()..color = const Color(0xFF1f3d22).withValues(alpha: 0.9),
    );
  }

  /// Scatters simple tree markers over open ground on tree-bearing biomes
  /// (matching [Biome.hasTrees]/`TerrainPainter`'s in-game placement), so an
  /// author can actually see where forest cover will appear - previously
  /// this preview never rendered trees at all. Deterministically seeded per
  /// cell (not a free-running [Random]) so trees stay put across repaints
  /// instead of jumping around every time the preview regenerates. Canopies
  /// lean with the sampled wind strength, giving the wind slider a visible
  /// effect even when there's no rain to show it.
  void _paintTrees(
    Canvas canvas,
    EditorTerrainPreview p,
    BiomePalette palette,
    double cellW,
    double cellH,
  ) {
    if (!palette.hasTrees) return;
    final windStrength = environment.sample(previewProgress).windStrength;
    for (var row = 0; row < p.grid.rows; row++) {
      for (var col = 0; col < p.grid.cols; col++) {
        if (p.obstacleKinds[row][col] != null) continue;
        final seed = row * 73856093 ^ col * 19349663;
        if (Random(seed).nextDouble() >= 0.12) continue;
        final center = Offset(col * cellW + cellW / 2, row * cellH + cellH / 2);
        _paintTreeMarker(canvas, center, min(cellW, cellH), windStrength);
      }
    }
  }

  /// Samples the weather timeline at [previewProgress] and draws cloud/fog
  /// tinting plus simple rain/snow overlays so timeline edits are visible.
  void _paintWeather(Canvas canvas, Rect rect, Size size) {
    final weather = environment.sample(previewProgress);

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
}
