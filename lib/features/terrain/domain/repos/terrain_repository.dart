import '../models/biome.dart';
import '../models/terrain_map.dart';

/// Provides the arena layout (mountain path + buildable pads) for a biome.
abstract class TerrainRepository {
  TerrainMap loadTerrain({required Biome biome});
}
