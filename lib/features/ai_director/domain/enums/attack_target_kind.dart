/// Where a massed skirmish attack squad should be sent once it's ready -
/// the AI director's (or [SkirmishDirective.fallback]'s) answer to "where
/// to attack", decided independently of "what to build"/"how many to
/// send" (see [SkirmishDirective.squadSize]).
enum AttackTargetKind {
  /// Beeline straight for the human player's home base - the default,
  /// always-available target.
  enemyBase,

  /// Focus the squad on whichever of the player's own towers currently has
  /// the lowest health fraction - picks off an already-damaged structure
  /// instead of always making a beeline for the base, falling back to
  /// [enemyBase] if the player has no towers up yet.
  weakestEnemyTower,
}
