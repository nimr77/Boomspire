import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../terrain/domain/models/terrain_map.dart';
import '../../terrain/domain/repos/terrain_repository.dart';
import 'widgets/level_select_biome_thumb_painter.dart';

/// Live small-scale render of a scene's actual terrain generation (not a
/// static image) - the same procedural painting used in-game, scaled down.
class BiomePreview extends StatelessWidget {
  final GameScene scene;

  final TerrainMap terrainMap;
  BiomePreview({super.key, required this.scene})
    : terrainMap = getIt<TerrainRepository>().loadTerrain(scene: scene);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: LevelSelectBiomeThumbPainter(terrainMap));
  }
}

