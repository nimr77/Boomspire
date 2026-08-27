import '../../../../core/combat/unit.dart';
import 'ally_movement_style.dart';
import 'ally_unit_type.dart';

/// Static stats for a friendly unit type - the Training Center/War Factory
/// counterpart of `EnemyBlueprint`.
class AllyUnitBlueprint with Unit {
  final AllyUnitType type;

  final String name;

  /// Gold cost to muster one of these from its Training Center/War Factory.
  final int cost;
  final double maxHealth;

  /// World pixels per second.
  final double speed;

  final double size;

  /// Damage dealt per shot to an enemy in range.
  final double attackDamage;

  /// Range at which this unit stops advancing to fire at an enemy.
  final double attackRange;

  /// Seconds between shots.
  final double attackInterval;

  /// The physical domain this unit occupies - ground units path-find
  /// around terrain, [UnitDomain.air] aircraft ignore it and fly straight
  /// to their target.
  @override
  final UnitDomain domain;

  /// Which domains this unit's weapon can hit - e.g. a ground-domain
  /// soldier with `{UnitDomain.ground}` can't shoot down an enemy
  /// helicopter/attack plane passing overhead.
  @override
  final Set<UnitDomain> attackDomains;

  /// Vehicles (tanks/light vehicles/aircraft) get an engine sound on spawn
  /// and a full explosion on death - infantry get a lighter cartoon "pop".
  final bool isVehicle;

  final AllyMovementStyle movementStyle;

  const AllyUnitBlueprint({
    required this.type,
    required this.name,
    required this.cost,
    required this.maxHealth,
    required this.speed,
    required this.size,
    required this.attackDamage,
    required this.attackRange,
    required this.attackInterval,
    this.domain = UnitDomain.ground,
    this.attackDomains = const {UnitDomain.ground},
    this.isVehicle = false,
    this.movementStyle = AllyMovementStyle.walk,
  });
}
