import '../../features/game_content/domain/models/game_object_definition.dart';
import '../../features/game_content/impl/game_object_definition_mapper.dart';
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
    // 5-round clip, 0.1s between shots, 1s reload once it's empty.
    UnitKind.soldier: MobileUnitBlueprint(
      kind: UnitKind.soldier,
      name: 'Soldier',
      maxHealth: 45,
      speed: 70,
      bounty: 12,
      size: 34,
      attackDamage: 4,
      attackRange: 130,
      attackInterval: 1.0,
      projectileCount: 5,
      clipShotInterval: 0.1,
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
    // enemy armor a real threat once it's in engagement range. One shot per
    // clip, 1s to reload.
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
      attackInterval: 1.0,
      movementStyle: MovementStyle.roll,
      weaponType: WeaponType.cannon,
    ),
    // Strafing-run attacker (see `MobileUnitComponent._updateStrafingRun`):
    // flies through its target firing a 4-round clip 0.5s apart, then
    // peels off to loop within 12 cells while its 2s reload runs, before
    // coming back around for another pass - like a real jet, not a
    // stationary turret.
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
      attackInterval: 2.0,
      projectileCount: 4,
      clipShotInterval: 0.5,
      movementStyle: MovementStyle.swoop,
      weaponType: WeaponType.rocket,
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
      clipShotInterval: 0.15,
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
    // New: a flak/SPAAG-style vehicle whose `attackDomains` cover both
    // ground and air, so it threatens ally aircraft/helicopters as well as
    // ground allies in the same volley.
    UnitKind.antiAirVehicle: MobileUnitBlueprint(
      kind: UnitKind.antiAirVehicle,
      name: 'Anti-Air Vehicle',
      maxHealth: 160,
      speed: 45,
      bounty: 48,
      size: 46,
      attackDomains: {UnitDomain.ground, UnitDomain.air},
      isVehicle: true,
      attackDamage: 9,
      projectileCount: 2,
      clipShotInterval: 0.12,
      attackRange: 210,
      attackInterval: 1.0,
      movementStyle: MovementStyle.roll,
      weaponType: WeaponType.cannon,
    ),
    // Flying-wing heavy bomber: same strafing-pass movement as Attack
    // Plane (see `MobileUnitComponent._updateStrafingRun`), but a single
    // heavy bomb per pass (`projectileCount: 1`) instead of a burst, and it
    // can only hit ground targets - a real dogfighter has to catch it,
    // not the other way around. Prefers shelling structures like Artillery
    // Barrage.
    UnitKind.stealthBomber: MobileUnitBlueprint(
      kind: UnitKind.stealthBomber,
      name: 'Stealth Bomber',
      maxHealth: 110,
      speed: 150,
      bounty: 90,
      size: 54,
      domain: UnitDomain.air,
      attackDomains: {UnitDomain.ground},
      isVehicle: true,
      attackDamage: 90,
      attackRange: 200,
      attackInterval: 3.0,
      movementStyle: MovementStyle.swoop,
      weaponType: WeaponType.rocket,
      prefersStructures: true,
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
      projectileCount: 5,
      clipShotInterval: 0.1,
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
      attackInterval: 1.0,
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
      attackInterval: 2.0,
      projectileCount: 4,
      clipShotInterval: 0.5,
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
    // Ground-only infantry, mustered from the Training Center alongside the
    // plain Soldier - hits much harder to justify its steeper cost.
    UnitKind.antiTankSoldier: MobileUnitBlueprint(
      kind: UnitKind.antiTankSoldier,
      name: 'Anti-Tank Soldier',
      cost: 70,
      maxHealth: 50,
      speed: 60,
      bounty: 25,
      size: 34,
      attackDamage: 26,
      attackRange: 150,
      attackInterval: 1.6,
      weaponType: WeaponType.rocket,
    ),
    // Infantry whose `attackDomains` includes air (unlike the plain
    // Soldier), so it can shoot down helicopters/planes - the Training
    // Center's answer to air threats.
    UnitKind.antiAirSoldier: MobileUnitBlueprint(
      kind: UnitKind.antiAirSoldier,
      name: 'Anti-Air Soldier',
      cost: 65,
      maxHealth: 45,
      speed: 65,
      bounty: 22,
      size: 34,
      attackDamage: 14,
      attackRange: 190,
      attackInterval: 1.2,
      attackDomains: {UnitDomain.ground, UnitDomain.air},
      weaponType: WeaponType.rocket,
    ),
    // Player-side counterpart of the enemy Stealth Bomber - same model,
    // same strafing-pass/single-bomb behavior, mustered from the War
    // Factory like the other vehicles.
    UnitKind.stealthBomber: MobileUnitBlueprint(
      kind: UnitKind.stealthBomber,
      name: 'Ally Stealth Bomber',
      cost: 260,
      maxHealth: 100,
      speed: 150,
      bounty: 95,
      size: 54,
      domain: UnitDomain.air,
      attackDomains: {UnitDomain.ground},
      isVehicle: true,
      attackDamage: 85,
      attackRange: 200,
      attackInterval: 3.0,
      movementStyle: MovementStyle.swoop,
      weaponType: WeaponType.rocket,
    ),
  };

  /// Synced game-content overrides (see `GameContentSyncService`) - empty
  /// by default, so every existing call site (including every test) gets
  /// today's hardcoded stats unchanged unless a successful sync supplied
  /// something newer.
  final List<GameObjectDefinition> overrides;
  MobileUnitRepositoryImpl({this.overrides = const []});

  @override
  MobileUnitBlueprint blueprintFor(Team team, UnitKind kind) {
    final table = _tableFor(team.catalog);
    final blueprint = table[kind];
    if (blueprint == null) {
      throw ArgumentError('$kind is not available to ${team.id}');
    }
    final override = findOverride(
      overrides,
      unitDefinitionId(team.catalog, kind.name),
    );
    return override == null
        ? blueprint
        : applyMobileUnitOverride(blueprint, override);
  }

  @override
  List<UnitKind> kindsFor(Team team) => _tableFor(team.catalog).keys.toList();

  Map<UnitKind, MobileUnitBlueprint> _tableFor(UnitCatalog catalog) =>
      switch (catalog) {
        UnitCatalog.invaderRoster => _enemyBlueprints,
        UnitCatalog.buildableRoster => _playerBlueprints,
      };
}
