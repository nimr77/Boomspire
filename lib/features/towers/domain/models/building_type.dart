import 'unit_type.dart';

/// Non-combat support structures - zero damage/range, built once (or up to
/// a small cap) to unlock capability rather than to fight directly.
enum BuildingType implements UnitType {
  techLab,
  commandPost,
  trainingCenter,
  warFactory,
  goldMine,
}
