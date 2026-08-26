import '../../../game_core/domain/models/game_scene.dart';
import '../models/terrain_map.dart';

/// Provides the arena layout (mountain path + buildable pads) for a scene.
abstract class TerrainRepository {
  TerrainMap loadTerrain({required GameScene scene});
}
