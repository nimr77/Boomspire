/// Every movable (non-tower) unit kind in the game - both the AI-enemy
/// roster and the player-buildable ally roster pick from this single enum
/// instead of each side inventing its own type, so a kind like `tank` means
/// the same shape/fire-type/domain shape on both sides (see
/// `MobileUnitRepository`), just with different stats and a different
/// [Team] color.
enum UnitKind {
  soldier,
  heavySoldier,
  tank,
  helicopter,
  attackPlane,
  gunboat,
  lightVehicle,
  aircraft,

  /// Long-range, slow, structure-hunting siege unit - prefers shelling
  /// towers over anything else (see `MobileUnitBlueprint.prefersStructures`).
  artilleryBarrage,

  /// Mobile rocket launcher - fielded by both sides (enemy AI roster and
  /// player War Factory production).
  rocketBarrage,
}
