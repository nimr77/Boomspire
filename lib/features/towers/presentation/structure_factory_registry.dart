import 'package:flame/components.dart';

import '../domain/models/building_type.dart';
import '../domain/models/tower_type.dart';
import '../domain/models/unit_blueprint.dart';
import '../domain/models/unit_type.dart';
import 'anti_air_tower_component.dart';
import 'artillery_bunker_component.dart';
import 'cannon_tower_component.dart';
import 'command_post_component.dart';
import 'gold_mine_component.dart';
import 'laser_tower_component.dart';
import 'machine_gun_tower_component.dart';
import 'rocket_silo_tower_component.dart';
import 'rocket_tower_component.dart';
import 'sam_tower_component.dart';
import 'tech_lab_component.dart';
import 'tower_component.dart';
import 'training_center_component.dart';
import 'war_factory_component.dart';

typedef TowerFactory = TowerComponent Function({
  required Vector2 position,
  required double cellSize,
  required UnitBlueprint blueprint,
});

/// Which concrete [TowerComponent] subclass to build for a given
/// [UnitType] - extracted from `BoomspireGame.createTower`'s switch so a
/// new buildable type is a one-line [register] call instead of a growing
/// switch statement.
class StructureFactoryRegistry {
  static final Map<UnitType, TowerFactory> _factories = {
    TowerType.machineGun: MachineGunTowerComponent.new,
    TowerType.rocket: RocketTowerComponent.new,
    TowerType.cannon: CannonTowerComponent.new,
    TowerType.antiAir: AntiAirTowerComponent.new,
    TowerType.laser: LaserTowerComponent.new,
    TowerType.rocketSilo: RocketSiloTowerComponent.new,
    TowerType.artilleryBunker: ArtilleryBunkerComponent.new,
    TowerType.sam: SamTowerComponent.new,
    BuildingType.techLab: TechLabComponent.new,
    BuildingType.commandPost: CommandPostComponent.new,
    BuildingType.trainingCenter: TrainingCenterComponent.new,
    BuildingType.warFactory: WarFactoryComponent.new,
    BuildingType.goldMine: GoldMineComponent.new,
  };

  static TowerComponent create(
    UnitType type, {
    required Vector2 position,
    required double cellSize,
    required UnitBlueprint blueprint,
  }) {
    final factory = _factories[type];
    if (factory == null) throw ArgumentError('Unknown unit type: $type');
    return factory(
      position: position,
      cellSize: cellSize,
      blueprint: blueprint,
    );
  }

  /// Lets new buildable types register their component without touching
  /// this file's map directly - mainly for tests exercising a fake type.
  static void register(UnitType type, TowerFactory factory) {
    _factories[type] = factory;
  }
}
