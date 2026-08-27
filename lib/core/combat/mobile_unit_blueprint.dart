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

  /// Total damage dealt per volley when engaging a target - split evenly
  /// across [projectileCount] shots if that's more than 1, so raising the
  /// round count changes the *shape* of an attack (a spread barrage instead
  /// of one shot) without silently also buffing its total damage.
  final double attackDamage;

  /// Range at which this unit will stop to fire.
  final double attackRange;

  /// Seconds between volleys.
  final double attackInterval;

  /// How many projectiles this unit launches simultaneously per volley -
  /// 1 for a single shot, more for a spread "barrage" (e.g. the Artillery
  /// Barrage's 3-rocket salvo). See `MobileUnitComponent._fireAt`.
  final int projectileCount;

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
    this.movementStyle = MovementStyle.walk,
    this.isVehicle = false,
    this.weaponType = WeaponType.bullet,
    this.bounty = 0,
    this.cost = 0,
    this.prefersStructures = false,
  });
}
