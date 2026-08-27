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
import 'package:boomspire/core/combat/team.dart';
import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/core/combat/unit_objective.dart';
import 'package:boomspire/core/combat/weapon_type.dart';
import 'package:boomspire/features/ai_director/impl/ai_director_repository_impl.dart';
import 'package:boomspire/features/audio/domain/models/sfx_type.dart';
import 'package:boomspire/features/audio/domain/repos/audio_repository.dart';
import 'package:boomspire/features/combat/presentation/mobile_unit_component.dart';
import 'package:boomspire/features/game_core/domain/models/game_config.dart';
import 'package:boomspire/features/game_core/domain/models/game_scene.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/game_core/domain/models/inspected_info.dart';
import 'package:boomspire/features/game_core/impl/game_state_repository_impl.dart';
import 'package:boomspire/features/game_core/presentation/boomspire_game.dart';
import 'package:boomspire/features/game_core/presentation/resource_node_component.dart';
import 'package:boomspire/features/terrain/impl/terrain_repository_impl.dart';
import 'package:boomspire/features/towers/domain/models/building_type.dart';
import 'package:boomspire/features/towers/domain/models/tower_type.dart';
import 'package:boomspire/features/towers/domain/models/unit_blueprint.dart';
import 'package:boomspire/features/towers/impl/building_repository_impl.dart';
import 'package:boomspire/features/towers/impl/tower_repository_impl.dart';
import 'package:boomspire/features/towers/presentation/machine_gun_tower_component.dart';
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

    test('single-use Tech Lab locks once built', () async {
      final game = await _bootGame(GameScenes.all.first);
      final grid = game.terrainMap.grid;
      expect(game.buildBlockReason(BuildingType.techLab), isNull);
      game.gameState.addGold(1000);

      final cell = _findOpenCell(game);
      game.selectTowerType(BuildingType.techLab);
      game.handleArenaTap(grid.cellCenter(cell));
      game.handleArenaTap(grid.cellCenter(cell));

      expect(game.towerCountFor(BuildingType.techLab), 1);
      expect(
        game.buildBlockReason(BuildingType.techLab),
        'Max 1 built',
        reason:
            'Tech Lab should report a lock reason once its 1-build cap '
            'is hit',
      );
    });

    test('Command Post and War Factory have no build cap - more than one can '
        'be built', () async {
      for (final type in [BuildingType.commandPost, BuildingType.warFactory]) {
        final game = await _bootGame(GameScenes.all.first);
        final grid = game.terrainMap.grid;
        game.gameState.addGold(5000);

        for (var i = 0; i < 3; i++) {
          expect(game.buildBlockReason(type), isNull);
          final cell = _findOpenCell(game);
          game.selectTowerType(type);
          game.handleArenaTap(grid.cellCenter(cell));
          game.handleArenaTap(grid.cellCenter(cell));
        }

        expect(game.towerCountFor(type), 3);
        expect(
          game.buildBlockReason(type),
          isNull,
          reason: '$type should never report a build-limit lock',
        );
      }
    });

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
        expect(game.world.unitsAlliedWith(game.playerTeam), isEmpty);

        final trainingCenter = game.world.activeTowers
            .whereType<TrainingCenterComponent>()
            .first;
        final startingGold = game.gameState.gold;
        expect(trainingCenter.canProduce, isTrue);
        expect(trainingCenter.produceSoldier(), isTrue);
        // Yield once so the ally's async sprite-load finishes mounting it.
        await Future<void>.delayed(Duration.zero);
        game.update(0);

        expect(game.world.unitsAlliedWith(game.playerTeam), isNotEmpty);
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
        expect(game.world.unitsAlliedWith(game.playerTeam), isEmpty);

        final warFactory = game.world.activeTowers
            .whereType<WarFactoryComponent>()
            .first;
        final startingGold = game.gameState.gold;
        expect(warFactory.produceUnit(UnitKind.tank), isTrue);
        await Future<void>.delayed(Duration.zero);
        game.update(0);

        expect(game.world.unitsAlliedWith(game.playerTeam), isNotEmpty);
        expect(
          game.gameState.gold,
          startingGold - warFactory.costFor(UnitKind.tank),
        );
        // Busy producing - a second request is refused until it cools down.
        expect(warFactory.produceUnit(UnitKind.aircraft), isFalse);
      },
    );

    test('Rocket Silo ignores enemies inside its minimum range', () async {
      final scene = GameScenes.all.first;
      final game = await _bootGame(scene);
      game.gameState.addGold(3000);
      final grid = game.terrainMap.grid;

      // Rocket Silo requires both Tech Lab and Command Post to be built
      // first (see `boomspire_game.dart`'s `buildBlockReason`).
      for (final prereq in [BuildingType.techLab, BuildingType.commandPost]) {
        final prereqCell = _findOpenCell(game);
        game.selectTowerType(prereq);
        game.handleArenaTap(grid.cellCenter(prereqCell));
        game.handleArenaTap(grid.cellCenter(prereqCell));
      }

      final cell = _findOpenCell(game);
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
      // Position is set only after mounting, since
      // MobileUnitComponent.onLoad overwrites `position` to a random spawn
      // point (for `UnitObjective.rushBase` units).
      final closeEnemy = MobileUnitComponent(
        blueprint: stationarySoldier,
        team: Team.invaders,
        objective: UnitObjective.rushBase,
      );
      game.world.spawnUnit(closeEnemy);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      closeEnemy.position = silo.position + Vector2(blueprint.minRange / 2, 0);
      for (var i = 0; i < 40; i++) {
        await Future<void>.delayed(Duration.zero);
        game.update(0.2);
      }
      expect(closeEnemy.health, closeEnemy.blueprint.maxHealth);

      // Enemy just outside the dead zone but still in range: gets hit.
      final farEnemy = MobileUnitComponent(
        blueprint: stationarySoldier,
        team: Team.invaders,
        objective: UnitObjective.rushBase,
      );
      game.world.spawnUnit(farEnemy);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      farEnemy.position = silo.position + Vector2(blueprint.minRange + 20, 0);
      for (var i = 0; i < 40; i++) {
        await Future<void>.delayed(Duration.zero);
        game.update(0.2);
      }
      expect(farEnemy.health, lessThan(farEnemy.blueprint.maxHealth));
    });
  });

  group('click-to-inspect', () {
    test(
      'tapping the player\'s own tower selects it, not the inspect card',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        final grid = game.terrainMap.grid;
        final cell = _findOpenCell(game);
        game.selectTowerType(TowerType.machineGun);
        game.handleArenaTap(grid.cellCenter(cell));
        game.handleArenaTap(grid.cellCenter(cell));

        final tower = game.world.activeTowers.first;
        game.handleArenaTap(tower.position);

        expect(game.selectedTower.value, tower);
        expect(game.inspected.value, isNull);
      },
    );

    test(
      'tapping an enemy tower shows its info instead of doing nothing',
      () async {
        final game = await _bootGame(GameScenes.skirmishes.first);
        final aiTeam = game.aiTeam!;
        final base = game.world.aiHomeBase!;
        final grid = game.terrainMap.grid;
        final baseCell = grid.worldToCell(base.position);
        final built = game.buildStructure(
          aiTeam,
          TowerType.machineGun,
          grid.cellCenter(Point(baseCell.x + 2, baseCell.y)),
        );
        expect(built, isNotNull);

        game.handleArenaTap(built!.position);

        expect(game.selectedTower.value, isNull);
        expect(game.inspected.value, isNotNull);
        expect(game.inspected.value!.kind, InspectedKind.tower);
        expect(game.inspected.value!.owner, aiTeam);
        expect(game.inspected.value!.name, built.blueprint.name);
      },
    );

    test('tapping any unit shows its info', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      const blueprint = MobileUnitBlueprint(
        kind: UnitKind.soldier,
        name: 'Test Soldier',
        maxHealth: 10,
        speed: 0,
        bounty: 0,
        size: 34,
      );
      final unit = MobileUnitComponent(
        blueprint: blueprint,
        team: game.aiTeam!,
        objective: UnitObjective.huntHostiles,
        position: Vector2(200, 200),
      );
      game.world.spawnUnit(unit);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      unit.position = Vector2(200, 200);

      game.handleArenaTap(unit.position);

      expect(game.inspected.value, isNotNull);
      expect(game.inspected.value!.kind, InspectedKind.unit);
      expect(game.inspected.value!.owner, game.aiTeam);
      expect(game.inspected.value!.name, blueprint.name);
    });

    test('tapping a resource node shows its info with a description', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final node = ResourceNodeComponent(position: Vector2(400, 300));
      game.world.activeResourceNodes.add(node);
      await game.world.add(node);

      game.handleArenaTap(node.position);

      expect(game.inspected.value, isNotNull);
      expect(game.inspected.value!.kind, InspectedKind.resourceNode);
      expect(game.inspected.value!.owner, isNull);
      expect(game.inspected.value!.description, isNotNull);
    });
  });

  group('skirmish AI parity', () {
    test(
      'both sides start a skirmish with the scene-scoped starting gold',
      () async {
        final game = await _bootGame(GameScenes.skirmishes.first);
        expect(game.gameState.gold, GameScenes.skirmishes.first.startingGold);
        expect(game.aiEconomy!.gold, GameScenes.skirmishes.first.startingGold);
      },
    );

    test('score-gated structures (Training Center, War Factory) are '
        'unlockable by both sides at zero score in skirmish - the score gate '
        'only applies to wave-defense', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final aiTeam = game.aiTeam!;
      expect(
        game.gameState.currentScore,
        lessThan(GameConfig.trainingCenterUnlockScore),
      );
      expect(
        game.gameState.currentScore,
        lessThan(GameConfig.warFactoryUnlockScore),
      );

      expect(
        game.canBuildTower(BuildingType.trainingCenter, owner: aiTeam),
        isTrue,
      );
      expect(
        game.canBuildTower(BuildingType.warFactory, owner: aiTeam),
        isTrue,
      );

      // Skirmish has no wave progression to gate on, so the human player
      // isn't score-gated there either, unlike in wave-defense (see the
      // dedicated wave-defense assertion below).
      expect(
        game.canBuildTower(BuildingType.trainingCenter, owner: game.playerTeam),
        isTrue,
      );
      expect(
        game.canBuildTower(BuildingType.warFactory, owner: game.playerTeam),
        isTrue,
      );

      final waveDefenseGame = await _bootGame(GameScenes.all.first);
      expect(
        waveDefenseGame.gameState.currentScore,
        lessThan(GameConfig.trainingCenterUnlockScore),
      );
      expect(
        waveDefenseGame.canBuildTower(BuildingType.trainingCenter),
        isFalse,
      );
    });

    test(
      'the AI is bound by the same per-type build limit and Tech Lab '
      'prerequisite as the player, independently of the player\'s own state',
      () async {
        final game = await _bootGame(GameScenes.skirmishes.first);
        final aiTeam = game.aiTeam!;
        final base = game.world.aiHomeBase!;

        // Laser Lance is locked for the AI until its own Tech Lab is up -
        // the player never builds one in this test, proving the gate is
        // tracked per-team rather than shared/global.
        expect(game.canBuildTower(TowerType.laser, owner: aiTeam), isFalse);

        Point<int>? cellFor(Vector2 origin, int ring) {
          final grid = game.terrainMap.grid;
          final baseCell = grid.worldToCell(origin);
          for (var dx = -ring; dx <= ring; dx++) {
            for (var dy = -ring; dy <= ring; dy++) {
              final cell = Point(baseCell.x + dx, baseCell.y + dy);
              if (!grid.inBounds(cell.x, cell.y)) continue;
              if (grid.isBlocked(cell.x, cell.y)) continue;
              return cell;
            }
          }
          return null;
        }

        final firstCell = cellFor(base.position, 2)!;
        final built = game.buildStructure(
          aiTeam,
          BuildingType.techLab,
          game.terrainMap.grid.cellCenter(firstCell),
        );
        expect(built, isNotNull);
        expect(game.towerCountFor(BuildingType.techLab, owner: aiTeam), 1);
        expect(game.canBuildTower(TowerType.laser, owner: aiTeam), isTrue);

        // A second Tech Lab is refused - same "max 1 built" cap the player
        // is bound by.
        final secondCell = cellFor(base.position, 3)!;
        final secondBuild = game.buildStructure(
          aiTeam,
          BuildingType.techLab,
          game.terrainMap.grid.cellCenter(secondCell),
        );
        expect(secondBuild, isNull);
        expect(game.towerCountFor(BuildingType.techLab, owner: aiTeam), 1);

        // The player's own prerequisite state is unaffected by the AI's.
        expect(
          game.canBuildTower(TowerType.laser, owner: game.playerTeam),
          isFalse,
        );
      },
    );

    test('buildStructure spends from the given owner\'s own wallet', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final aiTeam = game.aiTeam!;
      final base = game.world.aiHomeBase!;
      final playerGoldBefore = game.gameState.gold;
      final aiGoldBefore = game.aiEconomy!.gold;
      final grid = game.terrainMap.grid;
      final baseCell = grid.worldToCell(base.position);
      final cell = Point(baseCell.x + 2, baseCell.y);

      final built = game.buildStructure(
        aiTeam,
        TowerType.machineGun,
        grid.cellCenter(cell),
      );

      expect(built, isNotNull);
      expect(game.aiEconomy!.gold, lessThan(aiGoldBefore));
      expect(game.gameState.gold, playerGoldBefore);
    });

    test(
      'killing a player-built skirmish unit pays the AI, and vice versa',
      () async {
        final game = await _bootGame(GameScenes.skirmishes.first);
        final aiTeam = game.aiTeam!;
        const blueprint = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Soldier',
          maxHealth: 10,
          speed: 0,
          bounty: 25,
          size: 34,
        );

        final aiGoldBefore = game.aiEconomy!.gold;
        final playerUnit = MobileUnitComponent(
          blueprint: blueprint,
          team: game.playerTeam,
          objective: UnitObjective.assaultBase,
        );
        game.world.spawnUnit(playerUnit);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        playerUnit.takeDamage(blueprint.maxHealth.toDouble());
        expect(game.aiEconomy!.gold, aiGoldBefore + blueprint.bounty);

        final playerGoldBefore = game.gameState.gold;
        final aiUnit = MobileUnitComponent(
          blueprint: blueprint,
          team: aiTeam,
          objective: UnitObjective.assaultBase,
        );
        game.world.spawnUnit(aiUnit);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        aiUnit.takeDamage(blueprint.maxHealth.toDouble());
        expect(game.gameState.gold, greaterThan(playerGoldBefore));
      },
    );

    test('every buildable-roster unit kind pays a non-zero kill bounty '
        '(regression: skirmish kills used to pay 0 gold either way)', () {
      final repository = MobileUnitRepositoryImpl();
      for (final kind in [
        UnitKind.soldier,
        UnitKind.tank,
        UnitKind.lightVehicle,
        UnitKind.aircraft,
        UnitKind.rocketBarrage,
      ]) {
        final blueprint = repository.blueprintFor(Team.defaultPlayer, kind);
        expect(
          blueprint.bounty,
          greaterThan(0),
          reason: '$kind must pay a kill bounty in skirmish',
        );
      }
    });
  });

  group('combat damage fixes', () {
    test(
      'enemy vehicle splash damage also hits nearby ally units, not just '
      'towers/base (regression: cannon/rocket hits used to skip mobile '
      'units entirely whenever the firer was hostile to the player)',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        const stationaryAlly = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Ally',
          maxHealth: 1000,
          speed: 0,
          bounty: 0,
          size: 34,
        );
        final ally = MobileUnitComponent(
          blueprint: stationaryAlly,
          team: game.playerTeam,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(ally);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        ally.position = Vector2(400, 300);

        const stationaryTank = MobileUnitBlueprint(
          kind: UnitKind.tank,
          name: 'Test Enemy Tank',
          maxHealth: 500,
          speed: 0,
          bounty: 0,
          size: 50,
          attackDamage: 40,
          attackRange: 300,
          attackInterval: 0.3,
          isVehicle: true,
          weaponType: WeaponType.cannon,
        );
        final enemyTank = MobileUnitComponent(
          blueprint: stationaryTank,
          team: Team.invaders,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(enemyTank);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        enemyTank.position = Vector2(420, 300);

        for (var i = 0; i < 30; i++) {
          await Future<void>.delayed(Duration.zero);
          game.update(0.2);
        }

        expect(ally.health, lessThan(ally.blueprint.maxHealth));
      },
    );
  });

  group('manual unit control', () {
    test(
      'tapping the player\'s own unit selects it for direct orders',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        const blueprint = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Ally',
          maxHealth: 40,
          speed: 0,
          bounty: 0,
          size: 34,
        );
        final ally = MobileUnitComponent(
          blueprint: blueprint,
          team: game.playerTeam,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(ally);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        ally.position = Vector2(300, 300);

        game.handleArenaTap(ally.position);
        expect(game.selectedUnit.value, ally);
        expect(game.inspected.value, isNull);

        // Tapping it again deselects instead of re-selecting.
        game.handleArenaTap(ally.position);
        expect(game.selectedUnit.value, isNull);
      },
    );

    test('selecting a tower type to build deselects the previously-selected '
        'unit', () async {
      final game = await _bootGame(GameScenes.all.first);
      const blueprint = MobileUnitBlueprint(
        kind: UnitKind.soldier,
        name: 'Test Ally',
        maxHealth: 40,
        speed: 0,
        bounty: 0,
        size: 34,
      );
      final ally = MobileUnitComponent(
        blueprint: blueprint,
        team: game.playerTeam,
        objective: UnitObjective.huntHostiles,
      );
      game.world.spawnUnit(ally);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      ally.position = Vector2(300, 300);

      game.handleArenaTap(ally.position);
      expect(game.selectedUnit.value, ally);

      game.selectTowerType(TowerType.machineGun);
      expect(game.selectedUnit.value, isNull);
      expect(game.selectedTowerType.value, TowerType.machineGun);
    });

    test(
      'deselectAll clears unit/tower/build selections and inspect state',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        const blueprint = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Ally',
          maxHealth: 40,
          speed: 0,
          bounty: 0,
          size: 34,
        );
        final ally = MobileUnitComponent(
          blueprint: blueprint,
          team: game.playerTeam,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(ally);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        ally.position = Vector2(300, 300);

        game.handleArenaTap(ally.position);
        expect(game.selectedUnit.value, ally);

        game.deselectAll();
        expect(game.selectedUnit.value, isNull);
        expect(game.selectedTower.value, isNull);
        expect(game.selectedTowerType.value, isNull);
        expect(game.inspected.value, isNull);
        expect(game.pendingPlacement.value, isNull);
      },
    );

    test('tapping open ground while a unit is selected issues a move order '
        'it walks to and then holds at', () async {
      final game = await _bootGame(GameScenes.all.first);
      final grid = game.terrainMap.grid;
      final cell = _findOpenCell(game);
      final cellCenter = grid.cellCenter(cell);
      const blueprint = MobileUnitBlueprint(
        kind: UnitKind.soldier,
        name: 'Test Ally',
        maxHealth: 40,
        speed: 80,
        bounty: 0,
        size: 34,
      );
      final ally = MobileUnitComponent(
        blueprint: blueprint,
        team: game.playerTeam,
        objective: UnitObjective.huntHostiles,
      );
      game.world.spawnUnit(ally);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      ally.position = cellCenter.clone();

      game.handleArenaTap(ally.position);
      expect(game.selectedUnit.value, ally);

      // Offset just far enough to not land back on the unit itself, but
      // still well inside the same open cell.
      final orderPoint = cellCenter + Vector2(18, 0);
      game.handleArenaTap(orderPoint);
      expect(ally.underManualControl, isTrue);
      expect(ally.moveOrderTarget, isNotNull);

      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
        game.update(0.1);
      }

      // Arrived and holding - not reverted to auto-hunting anywhere else.
      expect(ally.moveOrderTarget, isNull);
    });

    test(
      'tapping an enemy while a unit is selected issues an attack order',
      () async {
        final game = await _bootGame(GameScenes.all.first);
        const allyBlueprint = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Ally',
          maxHealth: 40,
          speed: 0,
          bounty: 0,
          size: 34,
          attackDamage: 10,
          attackRange: 150,
          attackInterval: 0.2,
        );
        final ally = MobileUnitComponent(
          blueprint: allyBlueprint,
          team: game.playerTeam,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(ally);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        ally.position = Vector2(300, 300);

        const enemyBlueprint = MobileUnitBlueprint(
          kind: UnitKind.soldier,
          name: 'Test Enemy',
          maxHealth: 200,
          speed: 0,
          bounty: 0,
          size: 34,
        );
        final enemy = MobileUnitComponent(
          blueprint: enemyBlueprint,
          team: Team.invaders,
          objective: UnitObjective.huntHostiles,
        );
        game.world.spawnUnit(enemy);
        await Future<void>.delayed(Duration.zero);
        game.update(0);
        enemy.position = Vector2(340, 300);

        game.handleArenaTap(ally.position);
        expect(game.selectedUnit.value, ally);

        game.handleArenaTap(enemy.position);
        expect(ally.forcedTarget, enemy);

        for (var i = 0; i < 20; i++) {
          await Future<void>.delayed(Duration.zero);
          game.update(0.2);
        }

        expect(enemy.health, lessThan(enemy.blueprint.maxHealth));
      },
    );
  });

  group('tower targeting', () {
    const mgBlueprint = UnitBlueprint(
      type: TowerType.machineGun,
      name: 'Test MG',
      cost: 50,
      range: 300,
      damage: 10,
      fireRate: 0.2,
      maxHp: 100,
    );

    const enemyBlueprint = MobileUnitBlueprint(
      kind: UnitKind.soldier,
      name: 'Test Enemy',
      maxHealth: 200,
      speed: 0,
      bounty: 0,
      size: 34,
    );

    Future<MachineGunTowerComponent> spawnTower(
      BoomspireGame game,
      Vector2 position,
    ) async {
      final tower = MachineGunTowerComponent(
        position: position,
        cellSize: 40,
        blueprint: mgBlueprint,
      );
      game.world.spawnTower(tower);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      return tower;
    }

    Future<MobileUnitComponent> spawnEnemy(
      BoomspireGame game,
      Vector2 position, {
      double? maxHealth,
    }) async {
      final enemy = MobileUnitComponent(
        blueprint: maxHealth == null
            ? enemyBlueprint
            : MobileUnitBlueprint(
                kind: UnitKind.soldier,
                name: 'Test Enemy',
                maxHealth: maxHealth,
                speed: 0,
                bounty: 0,
                size: 34,
              ),
        team: Team.invaders,
        objective: UnitObjective.huntHostiles,
      );
      game.world.spawnUnit(enemy);
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      enemy.position = position;
      return enemy;
    }

    test('selecting a tower and tapping an enemy force-targets it even over '
        'a closer enemy', () async {
      final game = await _bootGame(GameScenes.all.first);
      final tower = await spawnTower(game, Vector2(200, 200));
      final nearEnemy = await spawnEnemy(game, Vector2(220, 200));
      final farEnemy = await spawnEnemy(game, Vector2(450, 200));

      game.handleArenaTap(tower.position);
      expect(game.selectedTower.value, tower);

      game.handleArenaTap(farEnemy.position);
      expect(tower.forcedTarget, farEnemy);

      game.update(0);
      expect(tower.currentTarget, farEnemy);
      expect(tower.currentTarget, isNot(nearEnemy));
    });

    test('no more than 3 towers focus-fire the same healthy enemy while a '
        'less-contested one is also in range', () async {
      final game = await _bootGame(GameScenes.all.first);
      final enemyA = await spawnEnemy(game, Vector2(450, 300));
      final enemyB = await spawnEnemy(game, Vector2(430, 300));

      // Towers are brought in one at a time (not all in the same frame)
      // so each one's join decision reflects an up-to-date targeter
      // count instead of every tower deciding off the same stale zero.
      final towers = <MachineGunTowerComponent>[];
      for (var i = 0; i < 4; i++) {
        final tower = await spawnTower(game, Vector2(200.0 + i * 5, 300));
        game.update(0.05);
        towers.add(tower);
      }

      final onEnemyA = towers.where((t) => t.currentTarget == enemyA);
      final onEnemyB = towers.where((t) => t.currentTarget == enemyB);
      expect(onEnemyA.length, lessThanOrEqualTo(3));
      // The 4th tower had nowhere less-contested to go on enemyA, so it
      // picked the other enemy instead of piling on regardless.
      expect(onEnemyB, isNotEmpty);
    });

    test('a near-dead target already being finished off by a fast tower is '
        'left alone by a much slower one, which retargets instead', () async {
      final game = await _bootGame(GameScenes.all.first);
      final fastKiller = MachineGunTowerComponent(
        position: Vector2(200, 300),
        cellSize: 40,
        blueprint: const UnitBlueprint(
          type: TowerType.machineGun,
          name: 'Fast Killer',
          cost: 50,
          range: 300,
          damage: 200,
          fireRate: 0.2,
          maxHp: 100,
        ),
      );
      game.world.spawnTower(fastKiller);
      final slowPoker = MachineGunTowerComponent(
        position: Vector2(220, 300),
        cellSize: 40,
        blueprint: const UnitBlueprint(
          type: TowerType.machineGun,
          name: 'Slow Poker',
          cost: 50,
          range: 300,
          damage: 1,
          fireRate: 0.2,
          maxHp: 100,
        ),
      );
      game.world.spawnTower(slowPoker);
      await Future<void>.delayed(Duration.zero);
      game.update(0);

      final nearDeathEnemy = await spawnEnemy(
        game,
        Vector2(450, 300),
        maxHealth: 1000,
      );
      final healthyEnemy = await spawnEnemy(game, Vector2(450, 330));

      // Both towers commit to the same (currently healthy) target first.
      game.update(0.05);
      fastKiller.currentTarget = nearDeathEnemy;
      slowPoker.currentTarget = nearDeathEnemy;

      // It then takes heavy damage and drops well under the near-death
      // threshold - `fastKiller` can one-shot what's left, `slowPoker`
      // very much can't.
      nearDeathEnemy.health = 10;
      game.update(0.05);

      expect(fastKiller.currentTarget, nearDeathEnemy);
      expect(slowPoker.currentTarget, healthyEnemy);
    });

    test('towers can target and damage an enemy tower/building, not just '
        'mobile units', () async {
      final game = await _bootGame(GameScenes.skirmishes.first);
      final aiTeam = game.aiTeam!;

      final playerTower = await spawnTower(game, Vector2(200, 200));
      final enemyTower = MachineGunTowerComponent(
        position: Vector2(220, 200),
        cellSize: 40,
        blueprint: mgBlueprint,
      )..owner = aiTeam;
      game.world.spawnTower(enemyTower);
      await Future<void>.delayed(Duration.zero);
      game.update(0);

      // Force-target the enemy tower directly, same as tapping it while
      // the player's own tower is selected (see `handleArenaTap`).
      playerTower.issueAttackOrder(enemyTower);
      final startingHealth = enemyTower.health;

      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
        game.update(0.25);
      }

      expect(playerTower.currentTarget, enemyTower);
      expect(enemyTower.health, lessThan(startingHealth));
    });
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
