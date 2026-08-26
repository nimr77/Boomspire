import '../models/terrain_map.dart';

/// Provides the arena layout (mountain path + buildable pads).
abstract class TerrainRepository {
  TerrainMap loadTerrain();
}
