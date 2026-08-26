import 'tower_type.dart';

/// Static combat stats and cost/space requirements for a tower type.
class TowerBlueprint {
  const TowerBlueprint({
    required this.type,
    required this.name,
    required this.cost,
    required this.range,
    required this.damage,
    required this.fireRate,
    this.splashRadius = 0,
  });

  final TowerType type;
  final String name;

  /// Gold cost to build - this is the "price" requirement.
  final int cost;

  /// Targeting radius in world pixels.
  final double range;

  final double damage;

  /// Seconds between shots.
  final double fireRate;

  /// Radius of splash damage on impact, 0 means single-target only.
  final double splashRadius;
}
