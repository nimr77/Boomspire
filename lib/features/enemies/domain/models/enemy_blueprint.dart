import '../../../../core/combat/unit.dart';
import 'enemy_movement_style.dart';
import 'enemy_type.dart';
import 'enemy_weapon_type.dart';

/// Static stats for an enemy type.
class EnemyBlueprint with Unit {
  final EnemyType type;

  final String name;
  final double maxHealth;

  /// World pixels per second.
  final double speed;

  /// Base gold reward when this enemy is killed.
  final int bounty;

  final double size;

  /// The physical domain this enemy occupies - ground troops/vehicles path
  /// around terrain, [UnitDomain.air] flyers ignore it and beeline for the
  /// base, [UnitDomain.sea] vessels sail the water tiles.
  @override
  final UnitDomain domain;

  /// Which domains this enemy's weapon can hit while engaging a tower or
  /// ally unit blocking its way - e.g. a ground-domain tank with
  /// `{UnitDomain.ground}` can't shoot down a friendly aircraft passing
  /// overhead.
  @override
  final Set<UnitDomain> attackDomains;

  /// Damage dealt per shot when engaging a tower blocking its way.
  final double attackDamage;

  /// Range at which this enemy will stop to fire at a tower.
  final double attackRange;

  /// Seconds between shots.
  final double attackInterval;

  /// How this unit's visual idles while moving (bob/rock/hover/wobble).
  final EnemyMovementStyle movementStyle;

  /// Vehicles (tanks/aircraft) get an engine sound on spawn, a sparking
  /// "about to blow" telegraph at low HP, and a full explosion + heavier
  /// SFX on death - infantry get a lighter cartoon "pop" instead.
  final bool isVehicle;

  /// Which projectile/effect this unit fires back at a tower it's engaging.
  final EnemyWeaponType weaponType;

  const EnemyBlueprint({
    required this.type,
    required this.name,
    required this.maxHealth,
    required this.speed,
    required this.bounty,
    required this.size,
    this.domain = UnitDomain.ground,
    this.attackDomains = const {UnitDomain.ground},
    this.attackDamage = 0,
    this.attackRange = 0,
    this.attackInterval = 1,
    this.movementStyle = EnemyMovementStyle.walk,
    this.isVehicle = false,
    this.weaponType = EnemyWeaponType.bullet,
  });
}
