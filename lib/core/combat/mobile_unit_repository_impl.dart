import 'mobile_unit_blueprint.dart';
import 'mobile_unit_repository.dart';
import 'movement_style.dart';
import 'team.dart';
import 'unit.dart';
import 'unit_kind.dart';
import 'weapon_type.dart';

class MobileUnitRepositoryImpl implements MobileUnitRepository {
  // Keyed by `isEnemy` rather than a specific Team instance, since any
  // number of human player Teams (future multiplayer seats) all draw from
  // the exact same "player" roster/stats - only their `Team.color` differs.
  static const _enemyBlueprints = <UnitKind, MobileUnitBlueprint>{
    UnitKind.soldier: MobileUnitBlueprint(
      kind: UnitKind.soldier,
      name: 'Soldier',
      maxHealth: 45,
      speed: 70,
      bounty: 12,
      size: 34,
      attackDamage: 4,
      attackRange: 130,
      attackInterval: 1.1,
    ),
    UnitKind.heavySoldier: MobileUnitBlueprint(
      kind: UnitKind.heavySoldier,
      name: 'Heavy Soldier',
      maxHealth: 150,
      speed: 40,
      bounty: 30,
      size: 46,
      attackDamage: 10,
      attackRange: 140,
      attackInterval: 1.4,
      weaponType: WeaponType.cannon,
    ),
    UnitKind.helicopter: MobileUnitBlueprint(
      kind: UnitKind.helicopter,
      name: 'Helicopter',
      maxHealth: 60,
      speed: 95,
      bounty: 22,
      size: 38,
      domain: UnitDomain.air,
      attackDomains: {UnitDomain.ground, UnitDomain.air},
      isVehicle: true,
      attackDamage: 6,
      attackRange: 160,
      attackInterval: 0.9,
      movementStyle: MovementStyle.hover,
      weaponType: WeaponType.rocket,
    ),
    // Stronger than before (was 280/14/150) - a deliberate ask to make
    // enemy armor a real threat once it's in engagement range.
    UnitKind.tank: MobileUnitBlueprint(
      kind: UnitKind.tank,
      name: 'Tank',
      maxHealth: 360,
      speed: 30,
      bounty: 60,
      size: 50,
      isVehicle: true,
      attackDamage: 20,
      attackRange: 160,
      attackInterval: 1.5,
      movementStyle: MovementStyle.roll,
      weaponType: WeaponType.cannon,
    ),
    UnitKind.attackPlane: MobileUnitBlueprint(
      kind: UnitKind.attackPlane,
      name: 'Attack Plane',
      maxHealth: 65,
      speed: 230,
      bounty: 40,
      size: 40,
      domain: UnitDomain.air,
      attackDomains: {UnitDomain.ground, UnitDomain.air},
      isVehicle: true,
      attackDamage: 45,
      attackRange: 180,
      attackInterval: 0.7,
      movementStyle: MovementStyle.swoop,
      weaponType: WeaponType.rocket,
    ),
    UnitKind.gunboat: MobileUnitBlueprint(
      kind: UnitKind.gunboat,
      name: 'Gunboat',
      maxHealth: 340,
      speed: 30,
      bounty: 55,
      size: 58,
      domain: UnitDomain.sea,
      attackDomains: {UnitDomain.ground, UnitDomain.sea},
      isVehicle: true,
      attackDamage: 18,
      attackRange: 210,
      attackInterval: 1.8,
      movementStyle: MovementStyle.sail,
      weaponType: WeaponType.cannon,
    ),
    // New: a slow, long-range siege unit that heads for the nearest tower
    // and shells it rather than rushing the base - see
    // `MobileUnitBlueprint.prefersStructures`. Fires its whole 3-rocket
    // salvo at once (`projectileCount`) instead of one shell, splitting the
    // volley's total damage across the 3 rockets.
    UnitKind.artilleryBarrage: MobileUnitBlueprint(
      kind: UnitKind.artilleryBarrage,
      name: 'Artillery Barrage',
      maxHealth: 200,
      speed: 26,
      bounty: 70,
      size: 52,
      isVehicle: true,
      attackDamage: 40,
      attackRange: 260,
      attackInterval: 2.4,
      projectileCount: 3,
      movementStyle: MovementStyle.roll,
      weaponType: WeaponType.rocket,
      prefersStructures: true,
    ),
    UnitKind.rocketBarrage: MobileUnitBlueprint(
      kind: UnitKind.rocketBarrage,
      name: 'Rocket Barrage',
      maxHealth: 180,
      speed: 34,
      bounty: 65,
      size: 50,
      attackDomains: {UnitDomain.ground, UnitDomain.air},
      isVehicle: true,
      attackDamage: 30,
      attackRange: 240,
      attackInterval: 2.0,
      movementStyle: MovementStyle.roll,
      weaponType: WeaponType.rocket,
    ),
  };

  // Note: these are the stats a fresh, un-upgraded Training Center/War
  // Factory produces - `AllyUnitComponent` scales health/damage up with the
  // producing building's `upgradeLevel`, so stronger ally units require
  // investing in that building first.
  static const _playerBlueprints = <UnitKind, MobileUnitBlueprint>{
    UnitKind.soldier: MobileUnitBlueprint(
      kind: UnitKind.soldier,
      name: 'Ally Soldier',
      cost: 40,
      maxHealth: 40,
      speed: 78,
      bounty: 15,
      size: 34,
      attackDamage: 4,
      attackRange: 130,
      attackInterval: 1.0,
    ),
    UnitKind.tank: MobileUnitBlueprint(
      kind: UnitKind.tank,
      name: 'Ally Tank',
      cost: 150,
      maxHealth: 170,
      speed: 34,
      bounty: 55,
      size: 50,
      attackDamage: 16,
      attackRange: 170,
      attackInterval: 1.6,
      isVehicle: true,
      movementStyle: MovementStyle.roll,
      weaponType: WeaponType.cannon,
    ),
    UnitKind.lightVehicle: MobileUnitBlueprint(
      kind: UnitKind.lightVehicle,
      name: 'Ally Light Vehicle',
      cost: 90,
      maxHealth: 80,
      speed: 96,
      bounty: 35,
      size: 38,
      attackDamage: 8,
      attackRange: 150,
      attackInterval: 0.8,
      isVehicle: true,
      movementStyle: MovementStyle.roll,
      weaponType: WeaponType.rocket,
    ),
    UnitKind.aircraft: MobileUnitBlueprint(
      kind: UnitKind.aircraft,
      name: 'Ally Aircraft',
      cost: 120,
      maxHealth: 60,
      speed: 130,
      bounty: 45,
      size: 40,
      attackDamage: 10,
      attackRange: 200,
      attackInterval: 0.9,
      domain: UnitDomain.air,
      attackDomains: {UnitDomain.ground, UnitDomain.air},
      isVehicle: true,
      movementStyle: MovementStyle.swoop,
      weaponType: WeaponType.rocket,
    ),
    // New: the player-side counterpart of the enemy Rocket Barrage -
    // mustered from the War Factory like the other vehicles.
    UnitKind.rocketBarrage: MobileUnitBlueprint(
      kind: UnitKind.rocketBarrage,
      name: 'Ally Rocket Barrage',
      cost: 220,
      maxHealth: 140,
      speed: 30,
      bounty: 80,
      size: 50,
      attackDamage: 22,
      attackRange: 230,
      attackInterval: 1.6,
      attackDomains: {UnitDomain.ground, UnitDomain.air},
      isVehicle: true,
      movementStyle: MovementStyle.roll,
      weaponType: WeaponType.rocket,
    ),
  };

  @override
  MobileUnitBlueprint blueprintFor(Team team, UnitKind kind) {
    final table = _tableFor(team.catalog);
    final blueprint = table[kind];
    if (blueprint == null) {
      throw ArgumentError('$kind is not available to ${team.id}');
    }
    return blueprint;
  }

  @override
  List<UnitKind> kindsFor(Team team) => _tableFor(team.catalog).keys.toList();

  Map<UnitKind, MobileUnitBlueprint> _tableFor(UnitCatalog catalog) =>
      switch (catalog) {
        UnitCatalog.invaderRoster => _enemyBlueprints,
        UnitCatalog.buildableRoster => _playerBlueprints,
      };
}
