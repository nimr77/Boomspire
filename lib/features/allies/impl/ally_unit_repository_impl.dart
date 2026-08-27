import '../domain/models/ally_movement_style.dart';
import '../domain/models/ally_unit_blueprint.dart';
import '../domain/models/ally_unit_type.dart';
import '../domain/repos/ally_unit_repository.dart';

class AllyUnitRepositoryImpl implements AllyUnitRepository {
  static const _blueprints = <AllyUnitType, AllyUnitBlueprint>{
    AllyUnitType.soldier: AllyUnitBlueprint(
      type: AllyUnitType.soldier,
      name: 'Ally Soldier',
      maxHealth: 60,
      speed: 78,
      size: 34,
      attackDamage: 6,
      attackRange: 130,
      attackInterval: 1.0,
    ),
    AllyUnitType.tank: AllyUnitBlueprint(
      type: AllyUnitType.tank,
      name: 'Ally Tank',
      maxHealth: 260,
      speed: 34,
      size: 50,
      attackDamage: 24,
      attackRange: 170,
      attackInterval: 1.6,
      isVehicle: true,
      movementStyle: AllyMovementStyle.roll,
    ),
    AllyUnitType.lightVehicle: AllyUnitBlueprint(
      type: AllyUnitType.lightVehicle,
      name: 'Ally Light Vehicle',
      maxHealth: 120,
      speed: 96,
      size: 38,
      attackDamage: 12,
      attackRange: 150,
      attackInterval: 0.8,
      isVehicle: true,
      movementStyle: AllyMovementStyle.roll,
    ),
    AllyUnitType.aircraft: AllyUnitBlueprint(
      type: AllyUnitType.aircraft,
      name: 'Ally Aircraft',
      maxHealth: 90,
      speed: 130,
      size: 40,
      attackDamage: 16,
      attackRange: 200,
      attackInterval: 0.9,
      isFlying: true,
      isVehicle: true,
      movementStyle: AllyMovementStyle.swoop,
    ),
  };

  @override
  AllyUnitBlueprint blueprintFor(AllyUnitType type) => _blueprints[type]!;
}
