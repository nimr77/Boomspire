import '../domain/models/tower_blueprint.dart';
import '../domain/models/tower_type.dart';
import '../domain/repos/tower_repository.dart';

class TowerRepositoryImpl implements TowerRepository {
  static const _blueprints = <TowerType, TowerBlueprint>{
    TowerType.machineGun: TowerBlueprint(
      type: TowerType.machineGun,
      name: 'Gatling Turret',
      cost: 40,
      range: 150,
      damage: 7,
      fireRate: 0.15,
    ),
    TowerType.rocket: TowerBlueprint(
      type: TowerType.rocket,
      name: 'Rocket Battery',
      cost: 90,
      range: 230,
      damage: 60,
      fireRate: 1.7,
      splashRadius: 75,
    ),
  };

  @override
  TowerBlueprint blueprintFor(TowerType type) => _blueprints[type]!;

  @override
  List<TowerBlueprint> get all => _blueprints.values.toList(growable: false);
}
