/// Player-selected challenge level, chosen at level select and threaded
/// through to the AI director's aggression (see `BoomspireGame.buildLimitFor`
/// for the per-tower-type build limits, which are now flat rather than
/// difficulty-scaled).
enum GameDifficulty { easy, normal, hard }

extension GameDifficultyX on GameDifficulty {
  String get label => switch (this) {
    GameDifficulty.easy => 'Easy',
    GameDifficulty.normal => 'Normal',
    GameDifficulty.hard => 'Hard',
  };

  /// Multiplies the AI director's (or its offline fallback's) computed
  /// aggression - harder difficulties mean bigger, faster waves on top of
  /// whatever the director already decided for the wave/scene.
  double get aggressionMultiplier => switch (this) {
    GameDifficulty.easy => 0.7,
    GameDifficulty.normal => 1.0,
    GameDifficulty.hard => 1.4,
  };
}
