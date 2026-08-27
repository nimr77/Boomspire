/// How a friendly unit's visual idles while moving - mirrors the enemy
/// side's movement styles but kept as its own small enum so the allies
/// feature doesn't need to depend on the enemies domain.
enum AllyMovementStyle {
  /// Infantry: gentle vertical bob (footsteps).
  walk,

  /// Ground vehicles: side-to-side rock (tread settling).
  roll,

  /// Aircraft: lazy banking wobble.
  swoop,
}
