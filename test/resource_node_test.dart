// Proves the capturable resource-node behavior: an uncontested vehicle
// claims a node after the capture window, and an owned node then pays its
// owner crystals on its payout tick. Non-vehicle units and contested nodes
// must not capture anything.
import 'package:boomspire/core/combat/mobile_unit_repository_impl.dart';
import 'package:boomspire/core/combat/team.dart';
import 'package:boomspire/core/combat/unit_objective.dart';
import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/features/ai_director/impl/ai_director_repository_impl.dart';
import 'package:boomspire/features/audio/domain/models/sfx_type.dart';
import 'package:boomspire/features/audio/domain/repos/audio_repository.dart';
import 'package:boomspire/features/combat/presentation/mobile_unit_component.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/game_core/impl/game_state_repository_impl.dart';
import 'package:boomspire/features/game_core/presentation/boomspire_game.dart';
import 'package:boomspire/features/game_core/presentation/resource_node_component.dart';
import 'package:boomspire/features/terrain/impl/terrain_repository_impl.dart';
import 'package:boomspire/features/towers/impl/building_repository_impl.dart';
import 'package:boomspire/features/towers/impl/tower_repository_impl.dart';
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

  test(
    'an uncontested vehicle captures a node then it pays out crystals',
    () async {
      final game = await _bootGame();
      final node = ResourceNodeComponent(position: Vector2(100, 100));
      await game.world.add(node);
      final tank = _spawnVehicle(game, Team.defaultPlayer, node.position);

      for (var i = 0; i < 50; i++) {
        game.update(0.1);
      }

      expect(node.owner, Team.defaultPlayer);

      final crystalsBefore = game.gameState.crystals;
      for (var i = 0; i < 70; i++) {
        game.update(0.1);
      }
      expect(game.gameState.crystals, greaterThan(crystalsBefore));

      tank.removeFromParent();
    },
  );

  test('a non-vehicle unit never captures a node', () async {
    final game = await _bootGame();
    final node = ResourceNodeComponent(position: Vector2(100, 100));
    await game.world.add(node);
    _spawnInfantry(game, Team.defaultPlayer, node.position);

    for (var i = 0; i < 100; i++) {
      game.update(0.1);
    }

    expect(node.owner, isNull);
  });

  test('two teams contesting a node prevents capture', () async {
    final game = await _bootGame();
    final node = ResourceNodeComponent(position: Vector2(100, 100));
    await game.world.add(node);
    _spawnVehicle(game, Team.defaultPlayer, node.position);
    _spawnVehicle(game, Team.invaders, node.position + Vector2(10, 0));

    for (var i = 0; i < 100; i++) {
      game.update(0.1);
    }

    expect(node.owner, isNull);
  });
}

MobileUnitComponent _spawnVehicle(
  BoomspireGame game,
  Team team,
  Vector2 position,
) {
  final blueprint = MobileUnitRepositoryImpl().blueprintFor(
    team,
    UnitKind.tank,
  );
  final unit = MobileUnitComponent(
    blueprint: blueprint,
    team: team,
    objective: UnitObjective.huntHostiles,
    position: position.clone(),
  );
  game.world.spawnUnit(unit);
  return unit;
}

MobileUnitComponent _spawnInfantry(
  BoomspireGame game,
  Team team,
  Vector2 position,
) {
  final blueprint = MobileUnitRepositoryImpl().blueprintFor(
    team,
    UnitKind.soldier,
  );
  final unit = MobileUnitComponent(
    blueprint: blueprint,
    team: team,
    objective: UnitObjective.huntHostiles,
    position: position.clone(),
  );
  game.world.spawnUnit(unit);
  return unit;
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

class _FakeAudioRepository implements AudioRepository {
  @override
  Future<void> preload() async {}

  @override
  void play(SfxType type, {double volume = 1.0}) {}
}
