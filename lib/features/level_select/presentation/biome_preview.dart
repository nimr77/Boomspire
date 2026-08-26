import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../terrain/domain/models/biome.dart';
import '../../terrain/domain/models/terrain_map.dart';
import '../../terrain/impl/terrain_repository_impl.dart';
import '../../terrain/presentation/terrain_painter.dart';

/// Live small-scale render of a biome's actual terrain generation (not a
/// static image) - the same procedural painting used in-game, scaled down.
class BiomePreview extends StatelessWidget {
  BiomePreview({super.key, required this.biome})
    : terrainMap = TerrainRepositoryImpl().loadTerrain(biome: biome);

  final Biome biome;
  final TerrainMap terrainMap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BiomeThumbPainter(terrainMap));
  }
}

class _BiomeThumbPainter extends CustomPainter {
  const _BiomeThumbPainter(this.terrainMap);

  final TerrainMap terrainMap;

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
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BiomeThumbPainter oldDelegate) =>
      oldDelegate.terrainMap != terrainMap;
}
