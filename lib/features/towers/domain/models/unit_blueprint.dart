import 'unit_type.dart';

/// Static combat stats and cost/space requirements for a buildable unit -
/// a combat tower ([TowerType]) or a support building ([BuildingType]).
class UnitBlueprint {
  final UnitType type;

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

  /// Structural health - enemies can shoot towers down.
  final double maxHp;

  final bool canTargetGround;

  final bool canTargetAir;
  const UnitBlueprint({
    required this.type,
    required this.name,
    required this.cost,
    required this.range,
    required this.damage,
    required this.fireRate,
    required this.maxHp,
    this.splashRadius = 0,
    this.canTargetGround = true,
    this.canTargetAir = false,
  });
}
