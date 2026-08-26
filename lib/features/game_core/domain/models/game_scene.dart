import '../../../terrain/domain/models/biome.dart';

/// Where the home base sits within the arena.
enum HomeLayout { eastEdge, center, northEastCorner, southWestCorner }

/// How many directions enemies attack from, relative to the base.
enum SpawnLayout {
  /// A single approach, opposite the base.
  single,

  /// Two opposing approaches.
  twoSided,

  /// Every open edge around the base.
  surround,
}

/// A playable scene: a terrain flavor (biome) paired with its own campaign
/// length, opening strategy, and the shape of its base/attack layout. Each
/// scene is a full, self-contained mission rather than just a re-skinned
/// map.
class GameScene {
  const GameScene({
    required this.id,
    required this.name,
    required this.briefing,
    required this.biome,
    required this.waveCount,
    required this.aggressionBias,
    required this.homeLayout,
    required this.spawnLayout,
  });

  final String id;
  final String name;

  /// Flavor text describing the terrain and the incoming strategy.
  final String briefing;
  final Biome biome;

  /// Total number of waves in this scene's campaign.
  final int waveCount;

  /// Added on top of the AI director's computed aggression each wave (0 =
  /// no change, higher = a harder-fought campaign from the start).
  final double aggressionBias;
  final HomeLayout homeLayout;
  final SpawnLayout spawnLayout;
}
