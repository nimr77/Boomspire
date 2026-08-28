import '../../../terrain/domain/models/biome.dart';
import '../enums/game_mode.dart';
import '../enums/home_layout.dart';
import '../enums/home_site_owner.dart';
import '../enums/spawn_layout.dart';

export '../enums/game_mode.dart';
export '../enums/home_layout.dart';
export '../enums/home_site_owner.dart';
export '../enums/spawn_layout.dart';

/// Pure version comparison - mirrors `GameObjectDefinition`'s `needsUpdate`
/// so a server-served [GameScene] only replaces a cached/built-in one when
/// it's actually newer.
bool sceneNeedsUpdate({
  required GameScene cached,
  required GameScene incoming,
}) => incoming.version > cached.version;

/// A playable scene: a terrain flavor (biome) paired with its own campaign
/// length, opening strategy, and the shape of its base/attack layout. Each
/// scene is a full, self-contained mission rather than just a re-skinned
/// map.
///
/// Scenes round-trip through [toJson]/[fromJson] so they can be authored as
/// data (see `assets/scenes/`) rather than only as Dart literals in
/// [GameScenes] - the foundation a future in-game scene/map builder writes
/// to.
class GameScene {
  final String id;

  final String name;

  /// Flavor text describing the terrain and the incoming strategy.
  final String briefing;

  final Biome biome;

  final GameMode mode;

  /// Total number of waves in this scene's campaign. Unused by
  /// [GameMode.skirmish] scenes.
  final int waveCount;

  /// Added on top of the AI director's computed aggression each wave (0 =
  /// no change, higher = a harder-fought campaign from the start). Unused
  /// by [GameMode.skirmish] scenes.
  final double aggressionBias;

  /// Unused by [GameMode.skirmish] scenes (see [homeSites] instead).
  final HomeLayout homeLayout;

  /// Unused by [GameMode.skirmish] scenes.
  final SpawnLayout spawnLayout;

  /// One entry per team seat, for [GameMode.skirmish] scenes - empty for
  /// [GameMode.waveDefense] scenes, which always use [homeLayout] instead.
  final List<HomeSite> homeSites;

  /// Capturable second-resource nodes on this scene's map - placed as a
  /// fraction of the arena size so the same scene definition still makes
  /// sense at any arena size. Empty for scenes with no capturable economy.
  final List<ResourceNodeSite> resourceNodeSites;

  /// Starting gold for this scene, or null to fall back to
  /// `GameConfig.startingGold`/`GameConfig.startingSkirmishGold` (picked by
  /// `mode`) - lets a scene/map draft author a different economy (e.g. the
  /// map editor's arena-size field) instead of only a single global constant.
  final int? startingGold;

  /// Bumped whenever any field above changes for this [id] - see
  /// [sceneNeedsUpdate]/`SceneSyncService`, which uses it to decide whether
  /// a server-served scene should replace a cached/built-in one.
  final int version;

  const GameScene({
    required this.id,
    required this.name,
    required this.briefing,
    required this.biome,
    this.mode = GameMode.waveDefense,
    this.waveCount = 0,
    this.aggressionBias = 0,
    this.version = 1,
    this.homeLayout = HomeLayout.eastEdge,
    this.spawnLayout = SpawnLayout.single,
    this.homeSites = const [],
    this.resourceNodeSites = const [],
    this.startingGold,
  });

  factory GameScene.fromJson(Map<String, dynamic> json) => GameScene(
    id: json['id'] as String,
    name: json['name'] as String,
    briefing: json['briefing'] as String,
    biome: Biome.values.byName(json['biome'] as String),
    mode: GameMode.values.byName(
      json['mode'] as String? ?? GameMode.waveDefense.name,
    ),
    waveCount: json['waveCount'] as int? ?? 0,
    aggressionBias: (json['aggressionBias'] as num?)?.toDouble() ?? 0,
    homeLayout: HomeLayout.values.byName(
      json['homeLayout'] as String? ?? HomeLayout.eastEdge.name,
    ),
    spawnLayout: SpawnLayout.values.byName(
      json['spawnLayout'] as String? ?? SpawnLayout.single.name,
    ),
    homeSites: (json['homeSites'] as List<dynamic>? ?? const [])
        .map((site) => HomeSite.fromJson(site as Map<String, dynamic>))
        .toList(),
    resourceNodeSites: (json['resourceNodeSites'] as List<dynamic>? ?? const [])
        .map((site) => ResourceNodeSite.fromJson(site as Map<String, dynamic>))
        .toList(),
    startingGold: json['startingGold'] as int?,
    version: json['version'] as int? ?? 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'briefing': briefing,
    'biome': biome.name,
    'mode': mode.name,
    'waveCount': waveCount,
    'aggressionBias': aggressionBias,
    'homeLayout': homeLayout.name,
    'spawnLayout': spawnLayout.name,
    'homeSites': homeSites.map((site) => site.toJson()).toList(),
    'resourceNodeSites': resourceNodeSites
        .map((site) => site.toJson())
        .toList(),
    if (startingGold != null) 'startingGold': startingGold,
    'version': version,
  };
}

/// One buildable home site on a skirmish map - a scene lists one per team
/// seat that can fight in that match.
class HomeSite {
  final HomeLayout layout;
  final HomeSiteOwner owner;

  const HomeSite({required this.layout, required this.owner});

  factory HomeSite.fromJson(Map<String, dynamic> json) => HomeSite(
    layout: HomeLayout.values.byName(json['layout'] as String),
    owner: HomeSiteOwner.values.byName(json['owner'] as String),
  );

  Map<String, dynamic> toJson() => {'layout': layout.name, 'owner': owner.name};
}

/// A capturable resource node's placement on a scene's map, as a fraction of
/// the arena size (0,0 = top-left, 1,1 = bottom-right) so the same scene
/// definition still makes sense at any arena size.
class ResourceNodeSite {
  final double dx;
  final double dy;

  const ResourceNodeSite({required this.dx, required this.dy});

  factory ResourceNodeSite.fromJson(Map<String, dynamic> json) =>
      ResourceNodeSite(
        dx: (json['dx'] as num).toDouble(),
        dy: (json['dy'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'dx': dx, 'dy': dy};
}
