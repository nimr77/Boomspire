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
      maxHp: 90,
    ),
    TowerType.rocket: TowerBlueprint(
      type: TowerType.rocket,
      name: 'Rocket Battery',
      cost: 90,
      range: 230,
      damage: 60,
      fireRate: 1.7,
      splashRadius: 75,
      maxHp: 120,
    ),
    TowerType.cannon: TowerBlueprint(
      type: TowerType.cannon,
      name: 'Siege Cannon',
      cost: 140,
      range: 190,
      damage: 95,
      fireRate: 2.4,
      splashRadius: 55,
      maxHp: 200,
    ),
    TowerType.antiAir: TowerBlueprint(
      type: TowerType.antiAir,
      name: 'Flak Battery',
      cost: 110,
      range: 260,
      damage: 26,
      fireRate: 0.5,
      maxHp: 100,
      canTargetGround: false,
      canTargetAir: true,
    ),
    TowerType.laser: TowerBlueprint(
      type: TowerType.laser,
      name: 'Laser Lance',
      cost: 170,
      range: 210,
      damage: 14,
      fireRate: 0.08,
      // Glass cannon: hits everything at a blistering rate but is fragile
      // enough that a single well-placed enemy rocket can take it out.
      maxHp: 35,
      canTargetGround: true,
      canTargetAir: true,
    ),
    TowerType.techLab: TowerBlueprint(
      type: TowerType.techLab,
      name: 'Tech Lab',
      cost: 60,
      range: 0,
      damage: 0,
      fireRate: 1,
      maxHp: 70,
    ),
  };

  @override
  List<TowerBlueprint> get all => _blueprints.values.toList(growable: false);

  @override
  TowerBlueprint blueprintFor(TowerType type) => _blueprints[type]!;
}
