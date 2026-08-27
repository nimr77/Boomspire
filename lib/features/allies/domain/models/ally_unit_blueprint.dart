import 'ally_movement_style.dart';
import 'ally_unit_type.dart';

/// Static stats for a friendly unit type - the Training Center/War Factory
/// counterpart of `EnemyBlueprint`.
class AllyUnitBlueprint {
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

  /// Aircraft ignore terrain/obstacles and fly straight to their target.
  final bool isFlying;

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
    this.isFlying = false,
    this.isVehicle = false,
    this.movementStyle = AllyMovementStyle.walk,
  });
}
