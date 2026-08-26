import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;

import '../../../core/rendering/procedural_image.dart';
import '../../game_core/presentation/circuit_defense_game.dart';
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
    with HasGameReference<CircuitDefenseGame> {
  final TerrainMap terrainMap;

  late final ui.Image _baseImage;
  ui.Path? _riverPath;
  double _riverPhase = 0;
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

    final selected = game.selectedTowerType.value;
    if (selected == null) return;
    final blueprint = game.towerRepository.blueprintFor(selected);
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
  }

  void _paintBase(ui.Canvas canvas) {
    TerrainPainter.paint(canvas, ui.Size(size.x, size.y), terrainMap);
  }
}
