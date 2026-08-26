import '../domain/models/enemy_blueprint.dart';
import '../domain/models/enemy_type.dart';
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
    ),
    EnemyType.air: EnemyBlueprint(
      type: EnemyType.air,
      name: 'Attack Drone',
      maxHealth: 60,
      speed: 95,
      bounty: 22,
      size: 38,
      isFlying: true,
      attackDamage: 6,
      attackRange: 160,
      attackInterval: 0.9,
    ),
  };

  @override
  EnemyBlueprint blueprintFor(EnemyType type) => _blueprints[type]!;
}
