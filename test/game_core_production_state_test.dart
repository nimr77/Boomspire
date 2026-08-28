// Proves GameCoreProductionState's build-menu computation for a selected
// Training Center/War Factory - the logic extracted out of
// GameCoreEntityPanelWidget's _produceButtons per the presentation
// state-layer rule.
import 'dart:math';

import 'package:boomspire/core/combat/mobile_unit_repository_impl.dart';
import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/core/rendering/impl/procedural_unit_render_repository_impl.dart';
import 'package:boomspire/features/ai_director/impl/ai_director_repository_impl.dart';
import 'package:boomspire/features/audio/domain/models/sfx_type.dart';
import 'package:boomspire/features/audio/domain/repos/audio_repository.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/game_core/impl/game_state_repository_impl.dart';
import 'package:boomspire/features/game_core/presentation/boomspire_game.dart';
import 'package:boomspire/features/game_core/presentation/state/game_core_production_state.dart';
import 'package:boomspire/features/terrain/impl/terrain_repository_impl.dart';
import 'package:boomspire/features/towers/domain/models/building_type.dart';
import 'package:boomspire/features/towers/impl/building_repository_impl.dart';
import 'package:boomspire/features/towers/impl/tower_repository_impl.dart';
import 'package:boomspire/features/towers/presentation/training_center_component.dart';
import 'package:boomspire/features/towers/presentation/war_factory_component.dart';
import 'package:boomspire/features/waves/impl/wave_repository_impl.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  final state = GameCoreProductionState();

  test('Training Center only offers its 3 fixed infantry kinds', () async {
    final game = await _bootGame();
    game.gameState.addGold(5000);
    final cell = _findOpenCell(game);
    final tower = game.buildStructure(
      game.playerTeam,
      BuildingType.trainingCenter,
      game.terrainMap.grid.cellCenter(cell),
    ) as TrainingCenterComponent;

    final options = state.optionsFor(game, tower);

    expect(
      options.map((o) => o.kind).toSet(),
      TrainingCenterComponent.producibleKinds.toSet(),
    );
    expect(options.every((o) => o.ready), isTrue);
  });

  test(
    'War Factory offers the buildable roster minus Training Center kinds',
    () async {
      final game = await _bootGame();
      game.gameState.addGold(5000);
      final cell = _findOpenCell(game);
      final tower = game.buildStructure(
        game.playerTeam,
        BuildingType.warFactory,
        game.terrainMap.grid.cellCenter(cell),
      ) as WarFactoryComponent;

      final options = state.optionsFor(game, tower);

      expect(options.map((o) => o.kind), isNot(contains(UnitKind.soldier)));
      expect(options, isNotEmpty);
    },
  );

  test(
    'affordable is false once gold drops below every option\'s cost',
    () async {
      final game = await _bootGame();
      game.gameState.addGold(600);
      final cell = _findOpenCell(game);
      final tower = game.buildStructure(
        game.playerTeam,
        BuildingType.trainingCenter,
        game.terrainMap.grid.cellCenter(cell),
      ) as TrainingCenterComponent;
      // Spend down to (near) zero so no option is affordable anymore.
      while (game.gameState.gold > 0) {
        if (!game.gameState.spendGold(game.gameState.gold)) break;
      }

      final options = state.optionsFor(game, tower);

      expect(options.every((o) => !o.affordable), isTrue);
    },
  );

  test('produce() spends gold and spawns a unit for the given kind', () async {
    final game = await _bootGame();
    game.gameState.addGold(5000);
    final cell = _findOpenCell(game);
    final tower = game.buildStructure(
      game.playerTeam,
      BuildingType.trainingCenter,
      game.terrainMap.grid.cellCenter(cell),
    ) as TrainingCenterComponent;
    final goldBefore = game.gameState.gold;
    final unitsBefore = game.world.activeUnits.length;

    state.produce(tower, UnitKind.soldier);

    expect(game.gameState.gold, lessThan(goldBefore));
    expect(game.world.activeUnits.length, unitsBefore + 1);
  });
}

Future<BoomspireGame> _bootGame() async {
  final scene = GameScenes.skirmishes.first;
  final game = BoomspireGame(
    terrainRepository: TerrainRepositoryImpl(),
    towerRepository: TowerRepositoryImpl(),
    buildingRepository: BuildingRepositoryImpl(),
    unitRepository: MobileUnitRepositoryImpl(),
    waveRepository: WaveRepositoryImpl(
      totalWaves: scene.waveCount,
      biome: scene.biome,
    ),
    audioRepository: _FakeAudioRepository(),
    gameState: GameStateRepositoryImpl(),
    aiDirector: AiDirectorRepositoryImpl(),
    unitRenderRepository: ProceduralUnitRenderRepositoryImpl(),
    scene: scene,
  );
  game.onGameResize(Vector2(1280, 720));
  // ignore: invalid_use_of_internal_member
  await game.load();
  // ignore: invalid_use_of_internal_member
  game.mount();
  game.update(0);
  return game;
}

/// Finds an open, buildable cell (not blocked, not spawn/base) so this test
/// doesn't depend on any particular random terrain layout.
Point<int> _findOpenCell(BoomspireGame game) {
  final grid = game.terrainMap.grid;
  final spawnCells = game.terrainMap.spawnPoints
      .map((sp) => grid.worldToCell(Vector2(sp.x, sp.y)))
      .toSet();
  final baseCell = grid.worldToCell(
    Vector2(game.terrainMap.basePoint.x, game.terrainMap.basePoint.y),
  );
  for (var row = 0; row < grid.rows; row++) {
    for (var col = 0; col < grid.cols; col++) {
      final cell = Point(col, row);
      if (!grid.isBlocked(col, row) &&
          !spawnCells.contains(cell) &&
          cell != baseCell) {
        return cell;
      }
    }
  }
  throw StateError('no open cell found');
}

class _FakeAudioRepository implements AudioRepository {
  @override
  void play(SfxType type, {double volume = 1.0}) {}

  @override
  Future<void> preload() async {}
}
