// Automated gameplay smoke tests: exercise the exact tap -> build pipeline
// that's otherwise only reachable via manual play, so regressions in tower
// placement/economy/pathfinding are caught by `flutter test` instead of
// needing a human (or flaky browser automation) to click through the game.
//
// These load the game directly (onGameResize/load/mount/update) instead of
// pumping a full widget tree, since that's much faster and all we need is
// the component tree mounted so tap handling and pathfinding work.
import 'dart:math';

import 'package:boomspire/core/combat/mobile_unit_blueprint.dart';
import 'package:boomspire/core/combat/mobile_unit_repository_impl.dart';
import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/features/ai_director/impl/ai_director_repository_impl.dart';
import 'package:boomspire/features/audio/domain/models/sfx_type.dart';
import 'package:boomspire/features/audio/domain/repos/audio_repository.dart';
import 'package:boomspire/features/enemies/presentation/green_soldier_component.dart';
import 'package:boomspire/features/game_core/domain/models/game_scene.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/game_core/impl/game_state_repository_impl.dart';
import 'package:boomspire/features/game_core/presentation/boomspire_game.dart';
import 'package:boomspire/features/terrain/impl/terrain_repository_impl.dart';
import 'package:boomspire/features/towers/domain/models/building_type.dart';
import 'package:boomspire/features/towers/domain/models/tower_type.dart';
import 'package:boomspire/features/towers/impl/building_repository_impl.dart';
import 'package:boomspire/features/towers/impl/tower_repository_impl.dart';
import 'package:boomspire/features/towers/presentation/rocket_silo_tower_component.dart';
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

  group('build pipeline', () {
    for (final scene in GameScenes.all) {
      test(
        'selecting + tapping an open cell places a tower (${scene.id})',
        () async {
          final game = await _bootGame(scene);
          final openCell = _findOpenCell(game);
          final startingGold = game.gameState.gold;

          game.selectTowerType(TowerType.machineGun);
          final cellCenter = game.terrainMap.grid.cellCenter(openCell);
          // First tap only previews the range/footprint; the same cell must
          // be tapped again to actually commit the build (see
          // BoomspireGame.pendingPlacement).
          game.handleArenaTap(cellCenter);
          expect(game.pendingPlacement.value, openCell);
          game.handleArenaTap(cellCenter);

          expect(
            game.gameState.gold,
            lessThan(startingGold),
            reason: 'gold should be spent after a successful build',
          );
          expect(game.world.activeTowers, hasLength(1));
        },
      );
    }

    test(
      'tapping a blocked (mountain/river) cell does not spend gold',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        final grid = game.terrainMap.grid;
        Point<int>? blockedCell;
        outer:
        for (var row = 0; row < grid.rows; row++) {
          for (var col = 0; col < grid.cols; col++) {
            if (grid.isBlocked(col, row)) {
              blockedCell = Point(col, row);
              break outer;
            }
          }
        }
        expect(blockedCell, isNotNull);

        final startingGold = game.gameState.gold;
        game.selectTowerType(TowerType.machineGun);
        game.handleArenaTap(grid.cellCenter(blockedCell!));

        expect(game.gameState.gold, startingGold);
        expect(game.world.activeTowers, isEmpty);
      },
    );

    test(
      'single-use buildings (Tech Lab, Command Post) lock once built',
      () async {
        for (final type in [BuildingType.techLab, BuildingType.commandPost]) {
          final game = await _bootGame(GameScenes.all.first);
          final grid = game.terrainMap.grid;
          expect(game.buildBlockReason(type), isNull);
          game.gameState.addGold(1000);

          final cell = _findOpenCell(game);
          game.selectTowerType(type);
          game.handleArenaTap(grid.cellCenter(cell));
          game.handleArenaTap(grid.cellCenter(cell));

          expect(game.towerCountFor(type), 1);
          expect(
            game.buildBlockReason(type),
            'Max 1 built',
            reason:
                '$type should report a lock reason once its 1-build cap is hit',
          );
        }
      },
    );

    test(
      'Training Center builds an Ally Soldier on demand from its menu',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        final grid = game.terrainMap.grid;
        game.gameState.addGold(1000);

        final cell = _findOpenCell(game);
        game.selectTowerType(BuildingType.trainingCenter);
        game.handleArenaTap(grid.cellCenter(cell));
        game.handleArenaTap(grid.cellCenter(cell));

        expect(game.towerCountFor(BuildingType.trainingCenter), 1);
        expect(game.world.activeAllies, isEmpty);

        final trainingCenter =
            game.world.activeTowers.whereType<TrainingCenterComponent>().first;
        final startingGold = game.gameState.gold;
        expect(trainingCenter.canProduce, isTrue);
        expect(trainingCenter.produceSoldier(), isTrue);
        // Yield once so the ally's async sprite-load finishes mounting it.
        await Future<void>.delayed(Duration.zero);
        game.update(0);

        expect(game.world.activeAllies, isNotEmpty);
        expect(game.gameState.gold, startingGold - trainingCenter.soldierCost);
        // A fresh production request is refused until the cooldown elapses.
        expect(trainingCenter.canProduce, isFalse);
        expect(trainingCenter.produceSoldier(), isFalse);
      },
    );

    test(
      'War Factory builds an Ally vehicle/aircraft on demand from its menu',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        final grid = game.terrainMap.grid;
        game.gameState.addGold(1000);

        final cell = _findOpenCell(game);
        game.selectTowerType(BuildingType.warFactory);
        game.handleArenaTap(grid.cellCenter(cell));
        game.handleArenaTap(grid.cellCenter(cell));

        expect(game.towerCountFor(BuildingType.warFactory), 1);
        expect(game.world.activeAllies, isEmpty);

        final warFactory =
            game.world.activeTowers.whereType<WarFactoryComponent>().first;
        final startingGold = game.gameState.gold;
        expect(warFactory.produceUnit(UnitKind.tank), isTrue);
        await Future<void>.delayed(Duration.zero);
        game.update(0);

        expect(game.world.activeAllies, isNotEmpty);
        expect(
          game.gameState.gold,
          startingGold - warFactory.costFor(UnitKind.tank),
        );
        // Busy producing - a second request is refused until it cools down.
        expect(warFactory.produceUnit(UnitKind.aircraft), isFalse);
      },
    );

    test(
      'Rocket Silo ignores enemies inside its minimum range',
      () async {
        final scene = GameScenes.all.first;
        final game = await _bootGame(scene);
        game.gameState.addGold(1000);
        final cell = _findOpenCell(game);
        final grid = game.terrainMap.grid;

        game.selectTowerType(TowerType.rocketSilo);
        game.handleArenaTap(grid.cellCenter(cell));
        game.handleArenaTap(grid.cellCenter(cell));
        final silo = game.world.activeTowers
            .whereType<RocketSiloTowerComponent>()
            .first;
        await Future<void>.delayed(Duration.zero);
        game.update(0);

        final blueprint = TowerRepositoryImpl().blueprintFor(
          TowerType.rocketSilo,
        );
        expect(blueprint.minRange, greaterThan(0));

        // Stationary (speed 0) so it can't just wander out of the tower's
        // reach before the tower has a chance to (not) engage it.
        const stationarySoldier = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Soldier',
          maxHealth: 1000,
          speed: 0,
          bounty: 0,
          size: 34,
        );

        // Enemy well inside the dead zone: should never take damage.
        // Position is set only after mounting, since EnemyComponent.onLoad
        // overwrites `position` to a random spawn point.
        final closeEnemy = GreenSoldierComponent(blueprint: stationarySoldier);
        game.world.spawnEnemy(closeEnemy);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        closeEnemy.position = silo.position + Vector2(blueprint.minRange / 2, 0);
        for (var i = 0; i < 40; i++) {
          await Future<void>.delayed(Duration.zero);
          game.update(0.2);
        }
        expect(closeEnemy.health, closeEnemy.blueprint.maxHealth);

        // Enemy just outside the dead zone but still in range: gets hit.
        final farEnemy = GreenSoldierComponent(blueprint: stationarySoldier);
        game.world.spawnEnemy(farEnemy);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        farEnemy.position = silo.position + Vector2(blueprint.minRange + 20, 0);
        for (var i = 0; i < 40; i++) {
          await Future<void>.delayed(Duration.zero);
          game.update(0.2);
        }
        expect(farEnemy.health, lessThan(farEnemy.blueprint.maxHealth));
      },
    );
  });

  test('every scene generates a terrain where every spawn can reach base', () {
    for (final scene in GameScenes.all) {
      final terrain = TerrainRepositoryImpl().loadTerrain(scene: scene);
      final grid = terrain.grid;
      final baseCell = grid.worldToCell(
        Vector2(terrain.basePoint.x, terrain.basePoint.y),
      );
      for (final spawnPoint in terrain.spawnPoints) {
        final spawnCell = grid.worldToCell(Vector2(spawnPoint.x, spawnPoint.y));
        expect(
          grid.isReachable(spawnCell, baseCell),
          isTrue,
          reason:
              '${scene.id} terrain must not fully wall off a spawn from base',
        );
      }
    }
  });
}

/// Boots a game without pumping a full Flutter widget tree (much faster).
Future<BoomspireGame> _bootGame(GameScene scene) async {
  final game = _newGame(scene);
  game.onGameResize(Vector2(1280, 720));
  // ignore: invalid_use_of_internal_member
  await game.load();
  // ignore: invalid_use_of_internal_member
  game.mount();
  game.update(0);
  return game;
}

/// Finds an open, buildable cell (not blocked, not spawn/base) so tests
/// don't depend on any particular random terrain layout.
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

BoomspireGame _newGame(GameScene scene) => BoomspireGame(
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

/// No-op audio - the real impl needs real audio plugins that aren't
/// available under `flutter test`.
class _FakeAudioRepository implements AudioRepository {
  @override
  void play(SfxType type, {double volume = 1}) {}

  @override
  Future<void> preload() async {}
}
