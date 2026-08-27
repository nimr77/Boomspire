import '../../../core/combat/unit.dart';
import '../../../generated/l10n.dart';
import '../domain/models/tower_type.dart';
import '../domain/models/unit_blueprint.dart';
import '../domain/repos/tower_repository.dart';

class TowerRepositoryImpl implements TowerRepository {
  @override
  List<UnitBlueprint> get all => _blueprints.values.toList(growable: false);

  Map<TowerType, UnitBlueprint> get _blueprints => <TowerType, UnitBlueprint>{
    TowerType.machineGun: UnitBlueprint(
      type: TowerType.machineGun,
      name: S.current.towerNameMachineGun,
      cost: 100,
      range: 150,
      damage: 7,
      fireRate: 0.15,
      maxHp: 90,
    ),
    TowerType.rocket: UnitBlueprint(
      type: TowerType.rocket,
      name: S.current.towerNameRocket,
      cost: 250,
      range: 230,
      damage: 60,
      fireRate: 1.7,
      splashRadius: 75,
      maxHp: 120,
    ),
    TowerType.cannon: UnitBlueprint(
      type: TowerType.cannon,
      name: S.current.towerNameCannon,
      cost: 300,
      range: 190,
      damage: 95,
      fireRate: 2.4,
      splashRadius: 55,
      maxHp: 200,
    ),
    TowerType.antiAir: UnitBlueprint(
      type: TowerType.antiAir,
      name: S.current.towerNameAntiAir,
      cost: 150,
      range: 260,
      damage: 26,
      fireRate: 0.5,
      maxHp: 100,
      attackDomains: const {UnitDomain.air},
    ),
    TowerType.laser: UnitBlueprint(
      type: TowerType.laser,
      name: S.current.towerNameLaser,
      cost: 1000,
      range: 210,
      damage: 14,
      fireRate: 0.08,
      // Glass cannon: hits everything at a blistering rate but is fragile
      // enough that a single well-placed enemy rocket can take it out.
      maxHp: 35,
      attackDomains: const {UnitDomain.ground, UnitDomain.air, UnitDomain.sea},
    ),
    TowerType.rocketSilo: UnitBlueprint(
      type: TowerType.rocketSilo,
      name: S.current.towerNameRocketSilo,
      range: 340,
      // Long-range-only siege weapon: anything that gets inside this radius
      // is under its minimum arc and can't be engaged at all - it relies on
      // other towers to screen it from close-range attackers.
      minRange: 130,
      damage: 90,
      cost: 500,
      // Slow reload to match its long-range-only role - it isn't meant to
      // duel anything up close, only pound targets from afar.
      fireRate: 4.5,
      splashRadius: 90,
      maxHp: 150,
      // Long-range siege weapon against ground and naval vehicles only -
      // no anti-air capability (see SAM Site for that job).
      attackDomains: const {UnitDomain.ground, UnitDomain.sea},
    ),
    TowerType.artilleryBunker: UnitBlueprint(
      type: TowerType.artilleryBunker,
      name: S.current.towerNameArtilleryBunker,
      cost: 800,
      range: 240,
      damage: 70,
      fireRate: 1.4,
      splashRadius: 40,
      maxHp: 160,
    ),
    TowerType.sam: UnitBlueprint(
      type: TowerType.sam,
      name: S.current.towerNameSam,
      // Longest anti-air range in the game - it's meant to snipe flyers
      // from far away, since it can't survive them getting close.
      range: 380,
      damage: 48,
      fireRate: 1.3,
      splashRadius: 20,
      // Very fragile - a couple of hits and it's gone.
      maxHp: 40,
      cost: 900,
      attackDomains: const {UnitDomain.air},
    ),
  };

  @override
  UnitBlueprint blueprintFor(TowerType type) => _blueprints[type]!;
}
