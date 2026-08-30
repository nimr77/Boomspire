import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../terrain/domain/models/obstacle_kind.dart';
import '../../../terrain/domain/models/terrain_map.dart';
import '../../../terrain/presentation/terrain_painter.dart';

/// Renders a [TerrainMap] scaled down into a small preview canvas - the
/// same procedural terrain painting used in-game, shrunk to thumbnail size.
class LevelSelectBiomeThumbPainter extends CustomPainter {
  final TerrainMap terrainMap;

  const LevelSelectBiomeThumbPainter(this.terrainMap);

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
    TerrainPainter.paintTrees(
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
    final lavaPath = TerrainPainter.riverPath(
      terrainMap,
      terrainMap.arenaHeight,
      kind: ObstacleKind.lava,
    );
    if (lavaPath != null) {
      TerrainPainter.paintLavaFlow(
        canvas,
        lavaPath,
        terrainMap.grid.cellSize,
        0,
      );
    }
    final lakeShape = TerrainPainter.lakeShape(terrainMap);
    if (lakeShape != null) {
      TerrainPainter.paintLakeFlow(
        canvas,
        lakeShape,
        terrainMap.grid.cellSize,
        0,
      );
    }
    final volcanicLakeShape = TerrainPainter.lakeShape(
      terrainMap,
      kind: ObstacleKind.volcanicLake,
    );
    if (volcanicLakeShape != null) {
      TerrainPainter.paintVolcanicLakeFlow(
        canvas,
        volcanicLakeShape,
        terrainMap.grid.cellSize,
        0,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LevelSelectBiomeThumbPainter oldDelegate) =>
      oldDelegate.terrainMap != terrainMap;
}
