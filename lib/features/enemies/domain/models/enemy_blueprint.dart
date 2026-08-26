import 'enemy_type.dart';

/// Static stats for an enemy type.
class EnemyBlueprint {
  final EnemyType type;

  final String name;
  final double maxHealth;

  /// World pixels per second.
  final double speed;

  /// Base gold reward when this enemy is killed.
  final int bounty;

  final double size;

  /// Flying enemies ignore terrain/tower obstacles and fly straight to base.
  final bool isFlying;

  /// Damage dealt per shot when engaging a tower blocking its way.
  final double attackDamage;

  /// Range at which this enemy will stop to fire at a tower.
  final double attackRange;

  /// Seconds between shots.
  final double attackInterval;

  const EnemyBlueprint({
    required this.type,
    required this.name,
    required this.maxHealth,
    required this.speed,
    required this.bounty,
    required this.size,
    this.isFlying = false,
    this.attackDamage = 0,
    this.attackRange = 0,
    this.attackInterval = 1,
  });
}
