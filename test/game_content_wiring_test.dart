import 'package:boomspire/core/combat/mobile_unit_repository_impl.dart';
import 'package:boomspire/core/combat/team.dart';
import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/features/game_content/domain/models/game_object_definition.dart';
import 'package:boomspire/features/game_content/impl/game_object_definition_mapper.dart';
import 'package:boomspire/features/towers/domain/models/building_type.dart';
import 'package:boomspire/features/towers/domain/models/tower_type.dart';
import 'package:boomspire/features/towers/impl/building_repository_impl.dart';
import 'package:boomspire/features/towers/impl/tower_repository_impl.dart';
import 'package:boomspire/features/towers/presentation/anti_air_tower_component.dart';
import 'package:boomspire/features/towers/presentation/gold_mine_component.dart';
import 'package:boomspire/features/towers/presentation/machine_gun_tower_component.dart';
import 'package:boomspire/features/towers/presentation/structure_factory_registry.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flame/game.dart' show Vector2;
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  group('synced game-content overrides', () {
    test('TowerRepositoryImpl keeps hardcoded stats with no overrides', () {
      final repo = TowerRepositoryImpl();
      final base = repo.blueprintFor(TowerType.machineGun);
      expect(TowerRepositoryImpl().blueprintFor(TowerType.machineGun).damage, base.damage);
    });

    test('TowerRepositoryImpl applies a synced override by id', () {
      final repo = TowerRepositoryImpl();
      final baseline = repo.blueprintFor(TowerType.machineGun);
      final override = towerToDefinition(baseline, version: 2).copyWith(damage: 999);

      final synced = TowerRepositoryImpl(overrides: [override]);
      final result = synced.blueprintFor(TowerType.machineGun);

      expect(result.damage, 999);
      // Name/type are never overridden - they don't travel over the wire.
      expect(result.name, baseline.name);
      expect(result.type, TowerType.machineGun);
      // Unrelated towers are untouched.
      expect(
        synced.blueprintFor(TowerType.rocket).damage,
        repo.blueprintFor(TowerType.rocket).damage,
      );
    });

    test('BuildingRepositoryImpl applies a synced override by id', () {
      final repo = BuildingRepositoryImpl();
      final baseline = repo.blueprintFor(BuildingType.techLab);
      final override = buildingToDefinition(baseline, version: 2).copyWith(cost: 12345);

      final synced = BuildingRepositoryImpl(overrides: [override]);

      expect(synced.blueprintFor(BuildingType.techLab).cost, 12345);
    });

    test('MobileUnitRepositoryImpl applies a synced override by id', () {
      final repo = MobileUnitRepositoryImpl();
      final baseline = repo.blueprintFor(Team.invaders, UnitKind.tank);
      final override = mobileUnitToDefinition(
        baseline,
        UnitCatalog.invaderRoster,
        version: 2,
      ).copyWith(maxHp: 4242);

      final synced = MobileUnitRepositoryImpl(overrides: [override]);
      final result = synced.blueprintFor(Team.invaders, UnitKind.tank);

      expect(result.maxHealth, 4242);
      // The player-side blueprint for the same UnitKind is a different id,
      // so it must stay untouched.
      expect(
        synced.blueprintFor(Team.defaultPlayer, UnitKind.tank).maxHealth,
        repo.blueprintFor(Team.defaultPlayer, UnitKind.tank).maxHealth,
      );
    });

    test('findOverride returns null when no id matches', () {
      expect(findOverride(const <GameObjectDefinition>[], 'tower.machineGun'), isNull);
    });
  });

  group('StructureFactoryRegistry', () {
    test('creates the correct concrete component per UnitType', () {
      final blueprint = TowerRepositoryImpl().blueprintFor(TowerType.machineGun);
      final tower = StructureFactoryRegistry.create(
        TowerType.machineGun,
        position: Vector2.zero(),
        cellSize: 64,
        blueprint: blueprint,
      );
      expect(tower, isA<MachineGunTowerComponent>());

      final buildingBlueprint = BuildingRepositoryImpl().blueprintFor(BuildingType.goldMine);
      final building = StructureFactoryRegistry.create(
        BuildingType.goldMine,
        position: Vector2.zero(),
        cellSize: 64,
        blueprint: buildingBlueprint,
      );
      expect(building, isA<GoldMineComponent>());
    });

    test('register() lets a new factory override an existing mapping', () {
      final blueprint = TowerRepositoryImpl().blueprintFor(TowerType.antiAir);
      StructureFactoryRegistry.register(
        TowerType.antiAir,
        ({required position, required cellSize, required blueprint}) =>
            AntiAirTowerComponent(position: position, cellSize: cellSize, blueprint: blueprint),
      );
      final tower = StructureFactoryRegistry.create(
        TowerType.antiAir,
        position: Vector2.zero(),
        cellSize: 64,
        blueprint: blueprint,
      );
      expect(tower, isA<AntiAirTowerComponent>());
    });
  });
}
