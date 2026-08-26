import '../domain/models/enemy_blueprint.dart';
import '../domain/models/enemy_movement_style.dart';
import '../domain/models/enemy_type.dart';
import '../domain/models/enemy_weapon_type.dart';
import '../domain/repos/enemy_repository.dart';

class EnemyRepositoryImpl implements EnemyRepository {
  static const _blueprints = <EnemyType, EnemyBlueprint>{
    EnemyType.soldier: EnemyBlueprint(
      type: EnemyType.soldier,
      name: 'Soldier',
      maxHealth: 45,
      speed: 70,
      bounty: 12,
      size: 34,
      attackDamage: 4,
      attackRange: 130,
      attackInterval: 1.1,
    ),
    EnemyType.heavySoldier: EnemyBlueprint(
      type: EnemyType.heavySoldier,
      name: 'Heavy Soldier',
      maxHealth: 150,
      speed: 40,
      bounty: 30,
      size: 46,
      attackDamage: 10,
      attackRange: 140,
      attackInterval: 1.4,
      weaponType: EnemyWeaponType.cannon,
    ),
    EnemyType.helicopter: EnemyBlueprint(
      type: EnemyType.helicopter,
      name: 'Helicopter',
      maxHealth: 60,
      speed: 95,
      bounty: 22,
      size: 38,
      isFlying: true,
      isVehicle: true,
      attackDamage: 6,
      attackRange: 160,
      attackInterval: 0.9,
      movementStyle: EnemyMovementStyle.hover,
      weaponType: EnemyWeaponType.rocket,
    ),
    EnemyType.tank: EnemyBlueprint(
      type: EnemyType.tank,
      name: 'Tank',
      maxHealth: 280,
      speed: 32,
      bounty: 45,
      size: 50,
      isVehicle: true,
      attackDamage: 14,
      attackRange: 150,
      attackInterval: 1.6,
      movementStyle: EnemyMovementStyle.roll,
      weaponType: EnemyWeaponType.cannon,
    ),
    EnemyType.attackPlane: EnemyBlueprint(
      type: EnemyType.attackPlane,
      name: 'Attack Plane',
      maxHealth: 65,
      speed: 230,
      bounty: 40,
      size: 40,
      isFlying: true,
      isVehicle: true,
      attackDamage: 9,
      attackRange: 180,
      attackInterval: 0.7,
      movementStyle: EnemyMovementStyle.swoop,
      weaponType: EnemyWeaponType.laser,
    ),
  };

  @override
  EnemyBlueprint blueprintFor(EnemyType type) => _blueprints[type]!;
}

