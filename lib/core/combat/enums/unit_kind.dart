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
  lightVehicle,
  aircraft,

  /// Long-range, slow, structure-hunting siege unit - prefers shelling
  /// towers over anything else (see `MobileUnitBlueprint.prefersStructures`).
  artilleryBarrage,

  /// Mobile rocket launcher - fielded by both sides (enemy AI roster and
  /// player War Factory production).
  rocketBarrage,

  /// Player-only infantry, buildable from the Training Center - ground-only
  /// but hits harder than a plain [soldier], themed as an anti-armor squad.
  antiTankSoldier,

  /// Player-only infantry, buildable from the Training Center - unlike a
  /// plain [soldier] its `attackDomains` include air, so it can shoot down
  /// helicopters/planes.
  antiAirSoldier,

  /// Enemy-only vehicle (a wave-defense invader) - a ground vehicle whose
  /// `attackDomains` include air, so it can shoot down player helicopters/
  /// aircraft as well as ground allies, not just one or the other.
  antiAirVehicle,

  /// Flying-wing heavy bomber, fielded by both sides - a slow, high-value
  /// air unit that flies a strafing-style pass (see
  /// `MobileUnitComponent._updateStrafingRun`) but drops a single heavy
  /// bomb per pass instead of a machine-gun-style burst. Shares one Lottie
  /// model (`ally_stealthBomber`/`enemy_stealthBomber` are the same
  /// silhouette) between both sides - team ownership is shown purely by the
  /// stripe overlay (see `TeamStripeMarkerComponent`), not by recoloring
  /// the model itself.
  stealthBomber,
}
