/// Which stat table a [Team] draws its `MobileUnitBlueprint`s from - takes
/// the place of the old `isEnemy ? enemyTable : playerTable` bool branch in
/// `MobileUnitRepository`, so adding a third roster later (e.g. a tougher
/// AI-faction catalog) is just one more enum value, not another flag.
enum UnitCatalog {
  /// Tougher, hand-tuned stats for AI-directed wave invaders - never
  /// player-buildable, so it has no per-kind gold [cost].
  invaderRoster,

  /// Every kind any builder team (the human player today, more later) can
  /// muster from a producing building, each priced with a gold [cost].
  buildableRoster,
}
