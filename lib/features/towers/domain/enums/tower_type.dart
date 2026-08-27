import '../models/unit_type.dart';

/// Combat towers - anything that actually fires at enemies. Non-combat
/// support structures live in [BuildingType] instead.
enum TowerType implements UnitType {
  machineGun,
  rocket,
  cannon,
  antiAir,
  laser,
  rocketSilo,
  artilleryBunker,
  sam,
}
