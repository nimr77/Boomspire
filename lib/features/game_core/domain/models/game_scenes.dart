import '../../../terrain/domain/models/biome.dart';
import 'game_scene.dart';

/// The full campaign catalog shown on the level-select screen. Every scene
/// pairs a biome with its own wave count, opening strategy bias, and base
/// placement/attack-direction layout.
class GameScenes {
  static const List<GameScene> all = [
    GameScene(
      id: 'green-line',
      name: 'Green Line',
      briefing:
          'Open fields, a single dirt road in from the west. A clean, '
          'standard defense to learn the ropes.',
      biome: Biome.grassPlains,
      waveCount: 6,
      aggressionBias: 0.0,
      homeLayout: HomeLayout.eastEdge,
      spawnLayout: SpawnLayout.single,
    ),
    GameScene(
      id: 'frozen-pincer',
      name: 'Frozen Pincer',
      briefing:
          'Your base sits exposed in the open tundra - the enemy splits '
          'its assault across two fronts at once.',
      biome: Biome.snowTundra,
      waveCount: 7,
      aggressionBias: 0.05,
      homeLayout: HomeLayout.center,
      spawnLayout: SpawnLayout.twoSided,
    ),
    GameScene(
      id: 'dune-siege',
      name: 'Dune Siege',
      briefing:
          'A dug-in corner outpost under siege from every direction '
          'across the dunes. No safe side.',
      biome: Biome.desertDunes,
      waveCount: 8,
      aggressionBias: 0.1,
      homeLayout: HomeLayout.northEastCorner,
      spawnLayout: SpawnLayout.surround,
    ),
    GameScene(
      id: 'forest-gauntlet',
      name: 'Forest Gauntlet',
      briefing:
          'The longest campaign - full encirclement through dense '
          'mountain forest, escalating wave after wave.',
      biome: Biome.mountainForest,
      waveCount: 9,
      aggressionBias: 0.15,
      homeLayout: HomeLayout.southWestCorner,
      spawnLayout: SpawnLayout.surround,
    ),
    GameScene(
      id: 'ruined-downtown',
      name: 'Ruined Downtown',
      briefing:
          'A collapsed skyline hems in your outpost - the enemy pushes '
          'in from two shattered avenues at once.',
      biome: Biome.cityRuins,
      waveCount: 7,
      aggressionBias: 0.1,
      homeLayout: HomeLayout.center,
      spawnLayout: SpawnLayout.twoSided,
    ),
    GameScene(
      id: 'savanna-crossing',
      name: 'Savanna Crossing',
      briefing:
          'Wide open grassland with nowhere to hide - a single dusty '
          'trail carries every assault straight for the base.',
      biome: Biome.savanna,
      waveCount: 6,
      aggressionBias: 0.05,
      homeLayout: HomeLayout.eastEdge,
      spawnLayout: SpawnLayout.single,
    ),
    GameScene(
      id: 'frozen-summit',
      name: 'Frozen Summit',
      briefing:
          'A dug-in summit outpost above the ice line, besieged from '
          'every ridge line around it.',
      biome: Biome.frozenPeaks,
      waveCount: 8,
      aggressionBias: 0.12,
      homeLayout: HomeLayout.northEastCorner,
      spawnLayout: SpawnLayout.surround,
    ),
    GameScene(
      id: 'coastal-blockade',
      name: 'Coastal Blockade',
      briefing:
          'A sea platform under blockade - gunboats shell the base from '
          'both open flanks across the water.',
      biome: Biome.sea,
      waveCount: 8,
      aggressionBias: 0.1,
      homeLayout: HomeLayout.center,
      spawnLayout: SpawnLayout.twoSided,
    ),
  ];

  /// Skirmish scenes: home-vs-home matches where every seat in
  /// [GameScene.homeSites] builds up and fights to destroy the others'
  /// homes, instead of surviving scripted waves. Only one seat is AI-owned
  /// for now (see the multiplayer/team-select plan for more seats).
  static const List<GameScene> skirmishes = [
    GameScene(
      id: 'twin-outposts',
      name: 'Twin Outposts',
      briefing:
          'Home against home across open grassland - build up and strike '
          'before the AI commander finishes theirs.',
      biome: Biome.grassPlains,
      mode: GameMode.skirmish,
      homeSites: [
        HomeSite(
          layout: HomeLayout.southWestCorner,
          owner: HomeSiteOwner.player,
        ),
        HomeSite(layout: HomeLayout.northEastCorner, owner: HomeSiteOwner.ai),
      ],
      // One contested node dead-center, plus one tucked closer to each
      // base - fought over by whichever side gets a vehicle there first.
      resourceNodeSites: [
        ResourceNodeSite(dx: 0.5, dy: 0.5),
        ResourceNodeSite(dx: 0.25, dy: 0.7),
        ResourceNodeSite(dx: 0.75, dy: 0.3),
      ],
    ),
  ];

  const GameScenes._();
}
