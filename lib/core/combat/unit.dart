export 'unit_domain.dart';

import 'unit_domain.dart';

/// Common contract + shared behavior for every combat-capable thing in the
/// game - tower/building blueprints, enemy blueprints, ally unit blueprints,
/// and the components built from them all mix this in instead of each
/// feature inventing its own isFlying/isNaval/canTargetGround/canTargetAir
/// booleans.
///
/// [domain] is the physical space this unit itself occupies; [attackDomains]
/// is the set of domains its weapon is capable of hitting. A ground-domain
/// tank whose [attackDomains] is just `{UnitDomain.ground}` can't hit an
/// air-domain plane - whether that plane is a friendly ally aircraft or an
/// enemy attack plane, since [canAttack] is checked the same way on both
/// sides of a fight.
abstract mixin class Unit {
  UnitDomain get domain;

  Set<UnitDomain> get attackDomains;

  bool canAttack(UnitDomain other) => attackDomains.contains(other);

  bool get isGroundUnit => domain == UnitDomain.ground;

  bool get isAirUnit => domain == UnitDomain.air;

  bool get isSeaUnit => domain == UnitDomain.sea;
}
