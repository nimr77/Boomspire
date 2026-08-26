import 'enemy_type.dart';

/// Static stats for an enemy type.
class EnemyBlueprint {
  const EnemyBlueprint({
    required this.type,
    required this.name,
    required this.maxHealth,
    required this.speed,
    required this.bounty,
    required this.size,
  });

  final EnemyType type;
  final String name;
  final double maxHealth;

  /// World pixels per second.
  final double speed;

  /// Base gold reward when this enemy is killed.
  final int bounty;

  final double size;
}
