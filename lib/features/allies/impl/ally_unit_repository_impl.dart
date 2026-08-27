import '../../../core/combat/unit.dart';
import '../domain/models/ally_movement_style.dart';
import '../domain/models/ally_unit_blueprint.dart';
import '../domain/models/ally_unit_type.dart';
import '../domain/repos/ally_unit_repository.dart';

class AllyUnitRepositoryImpl implements AllyUnitRepository {
  static const _blueprints = <AllyUnitType, AllyUnitBlueprint>{
    // Note: these are the stats a fresh, un-upgraded Training Center/War
    // Factory produces - `AllyUnitComponent` scales health/damage up with
    // the producing building's `upgradeLevel` (see `_levelMultiplier`), so
    // stronger ally units require investing in that building first.
    AllyUnitType.soldier: AllyUnitBlueprint(
      type: AllyUnitType.soldier,
      name: 'Ally Soldier',
      cost: 40,
      maxHealth: 40,
      speed: 78,
      size: 34,
      attackDamage: 4,
      attackRange: 130,
      attackInterval: 1.0,
    ),
    AllyUnitType.tank: AllyUnitBlueprint(
      type: AllyUnitType.tank,
      name: 'Ally Tank',
      cost: 150,
      maxHealth: 170,
      speed: 34,
      size: 50,
      attackDamage: 16,
      attackRange: 170,
      attackInterval: 1.6,
      isVehicle: true,
      movementStyle: AllyMovementStyle.roll,
    ),
    AllyUnitType.lightVehicle: AllyUnitBlueprint(
      type: AllyUnitType.lightVehicle,
      name: 'Ally Light Vehicle',
      cost: 90,
      maxHealth: 80,
      speed: 96,
      size: 38,
      attackDamage: 8,
      attackRange: 150,
      attackInterval: 0.8,
      isVehicle: true,
      movementStyle: AllyMovementStyle.roll,
    ),
    AllyUnitType.aircraft: AllyUnitBlueprint(
      type: AllyUnitType.aircraft,
      name: 'Ally Aircraft',
      cost: 120,
      maxHealth: 60,
      speed: 130,
      size: 40,
      attackDamage: 10,
      attackRange: 200,
      attackInterval: 0.9,
      domain: UnitDomain.air,
      attackDomains: {UnitDomain.ground, UnitDomain.air},
      isVehicle: true,
      movementStyle: AllyMovementStyle.swoop,
    ),
  };

  @override
  AllyUnitBlueprint blueprintFor(AllyUnitType type) => _blueprints[type]!;
}
