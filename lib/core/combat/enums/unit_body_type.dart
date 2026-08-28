/// Physical "body" family of a mobile unit - drives shared movement/combat
/// visual behavior (engine smoke vs none, track/dust vs nothing, turret
/// rotation, leg/arm firing animation) that every unit sharing that family
/// gets regardless of its specific `UnitKind` stats. Mirrors the
/// `UnitType`/`TowerType`/`BuildingType` `implements Enum` convention, just
/// one layer deeper: [Human]/[Vehicle] are themselves abstract marker
/// classes, and a concrete leaf enum ([HumanUnitType]/[VehicleUnitType])
/// implements whichever family it belongs to.
abstract class UnitBodyType implements Enum {}

/// Infantry: walks under its own legs, animates legs/arms while shooting,
/// never emits engine smoke and leaves no track/dust behind.
abstract class Human implements UnitBodyType {}

/// Motorized units: emit engine smoke while moving - see `VehicleUnitType`
/// for the wheel/track/air-specific sub-behaviors (turret rotation, tread
/// marks vs dust, jet exhaust).
abstract class Vehicle implements UnitBodyType {}
