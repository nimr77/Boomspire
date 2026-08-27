import '../../../../core/combat/unit.dart';
import 'unit_type.dart';

/// Static combat stats and cost/space requirements for a buildable unit -
/// a combat tower ([TowerType]) or a support building ([BuildingType]).
///
/// Note: this [UnitType] (buildable-on-the-grid marker) is unrelated to the
/// [Unit] mixin below (domain/attackDomains contract) - a tower is a
/// [UnitType] AND, via this blueprint, a [Unit].
class UnitBlueprint with Unit {
  final UnitType type;

  final String name;

  /// Gold cost to build - this is the "price" requirement.
  final int cost;

  /// Targeting radius in world pixels.
  final double range;

  /// Minimum engagement radius - enemies closer than this are ignored, so
  /// long-range-only weapons (e.g. the Rocket Silo) can't be plinked by
  /// units that get in right under their barrels. 0 means no dead zone.
  final double minRange;

  final double damage;

  /// Seconds between shots.
  final double fireRate;

  /// Radius of splash damage on impact, 0 means single-target only.
  final double splashRadius;

  /// Structural health - enemies can shoot towers down.
  final double maxHp;

  /// Towers/buildings are always ground-domain structures sitting on the
  /// grid - only [attackDomains] (what they can shoot) varies.
  @override
  final UnitDomain domain;

  @override
  final Set<UnitDomain> attackDomains;

  const UnitBlueprint({
    required this.type,
    required this.name,
    required this.cost,
    required this.range,
    required this.damage,
    required this.fireRate,
    required this.maxHp,
    this.splashRadius = 0,
    this.minRange = 0,
    this.domain = UnitDomain.ground,
    this.attackDomains = const {UnitDomain.ground, UnitDomain.sea},
  });
}
