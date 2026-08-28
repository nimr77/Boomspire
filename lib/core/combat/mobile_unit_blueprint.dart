import 'movement_style.dart';
import 'unit.dart';
import 'unit_kind.dart';
import 'weapon_type.dart';

/// Static stats for a mobile unit type - shape (via `buildSprite()` on the
/// component subclass), fire (weapon type/damage/range), and domain all come
/// from one of these, resolved through `MobileUnitRepository`. Replaces the
/// old separate `EnemyBlueprint`/`AllyUnitBlueprint` so both sides are
/// driven by the exact same data shape - only the owning `Team` (and
/// therefore its color) differs.
class MobileUnitBlueprint with Unit {
  final UnitKind kind;
  final String name;
  final double maxHealth;

  /// World pixels per second.
  final double speed;

  final double size;

  /// The physical domain this unit occupies - ground units path-find
  /// around terrain, [UnitDomain.air] flyers ignore it, [UnitDomain.sea]
  /// vessels sail the water tiles.
  @override
  final UnitDomain domain;

  /// Which domains this unit's weapon can hit while engaging something
  /// blocking its way.
  @override
  final Set<UnitDomain> attackDomains;

  // --- Attack profile: attack type (`weaponType`), damage, range, rate of
  // fire, and rounds per volley (`projectileCount`) - the full set a player
  // or designer needs to reason about how this unit fights, kept together
  // here so every mobile unit (enemy or ally) states its attack the same
  // way instead of each component inventing its own firing shape.

  /// Total damage dealt per clip when engaging a target - split evenly
  /// across [projectileCount] shots if that's more than 1, so raising the
  /// round count changes the *shape* of an attack (a spread barrage instead
  /// of one shot) without silently also buffing its total damage.
  final double attackDamage;

  /// Range at which this unit will stop (or, for a strafing plane, start
  /// its firing pass) to fire.
  final double attackRange;

  /// Seconds to reload once a full clip ([projectileCount] shots) has been
  /// fired - for a 1-round clip (the default) this is just the plain
  /// per-shot rate of fire, same as before clips existed.
  final double attackInterval;

  /// How many rounds this unit's clip holds before it must reload - 1 for a
  /// single shot, more for a burst fired one round at a time, each
  /// [clipShotInterval] apart, before [attackInterval]'s reload kicks in
  /// (e.g. a Soldier's 5-round clip, or the Artillery Barrage's 3-round
  /// salvo). See `MobileUnitComponent._fireOneRound`.
  final int projectileCount;

  /// Seconds between each shot within a clip once [projectileCount] > 1 -
  /// has no effect for a 1-round clip.
  final double clipShotInterval;

  /// How this unit's visual idles while moving.
  final MovementStyle movementStyle;

  /// Vehicles get an engine sound on spawn, a low-HP smoke telegraph (enemy
  /// side), and a full explosion + heavier SFX on death - infantry get a
  /// lighter cartoon "pop" instead.
  final bool isVehicle;

  /// Which projectile/effect this unit fires at whatever it's engaging.
  final WeaponType weaponType;

  /// Gold reward when an enemy-team unit of this blueprint is killed (0 for
  /// player-only kinds).
  final int bounty;

  /// Gold cost to muster this from a Training Center/War Factory (0 for
  /// enemy-only kinds).
  final int cost;

  /// Artillery-style units bias their targeting hard toward towers/
  /// structures over other mobile units, and only fall back to rushing the
  /// base if no structure is in range - see `EnemyComponent._scoreFor`.
  final bool prefersStructures;

  /// Only targetable once an attacker is within
  /// `GameConfig.stealthDetectionRangeCells` grid cells of it - see
  /// `isTargetDetectable` in `mobile_unit_component.dart`.
  final bool isStealth;

  const MobileUnitBlueprint({
    required this.kind,
    required this.name,
    required this.maxHealth,
    required this.speed,
    required this.size,
    this.domain = UnitDomain.ground,
    this.attackDomains = const {UnitDomain.ground},
    this.attackDamage = 0,
    this.attackRange = 0,
    this.attackInterval = 1,
    this.projectileCount = 1,
    this.clipShotInterval = 0.12,
    this.movementStyle = MovementStyle.walk,
    this.isVehicle = false,
    this.weaponType = WeaponType.bullet,
    this.bounty = 0,
    this.cost = 0,
    this.prefersStructures = false,
    this.isStealth = false,
  });
}
