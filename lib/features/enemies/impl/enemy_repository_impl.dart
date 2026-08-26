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
    ),
    EnemyType.heavySoldier: EnemyBlueprint(
      type: EnemyType.heavySoldier,
      name: 'Heavy Soldier',
      maxHealth: 150,
      speed: 40,
      bounty: 30,
      size: 46,
    ),
  };

  @override
  EnemyBlueprint blueprintFor(EnemyType type) => _blueprints[type]!;
}
