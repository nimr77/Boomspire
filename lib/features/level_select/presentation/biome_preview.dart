import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../terrain/domain/models/terrain_map.dart';
import '../../terrain/domain/repos/terrain_repository.dart';
import '../../terrain/presentation/terrain_painter.dart';

/// Live small-scale render of a scene's actual terrain generation (not a
/// static image) - the same procedural painting used in-game, scaled down.
class BiomePreview extends StatelessWidget {
  final GameScene scene;

  final TerrainMap terrainMap;
  BiomePreview({super.key, required this.scene})
    : terrainMap = getIt<TerrainRepository>().loadTerrain(scene: scene);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BiomeThumbPainter(terrainMap));
  }
}

class _BiomeThumbPainter extends CustomPainter {
  final TerrainMap terrainMap;

  const _BiomeThumbPainter(this.terrainMap);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.save();
    canvas.clipRect(ui.Offset.zero & size);
    canvas.scale(
      size.width / terrainMap.arenaWidth,
      size.height / terrainMap.arenaHeight,
    );
    TerrainPainter.paint(
      canvas,
      ui.Size(terrainMap.arenaWidth, terrainMap.arenaHeight),
      terrainMap,
    );
    final riverPath = TerrainPainter.riverPath(
      terrainMap,
      terrainMap.arenaHeight,
    );
    if (riverPath != null) {
      TerrainPainter.paintRiverFlow(
        canvas,
        riverPath,
        terrainMap.grid.cellSize,
        0,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BiomeThumbPainter oldDelegate) =>
      oldDelegate.terrainMap != terrainMap;
}
