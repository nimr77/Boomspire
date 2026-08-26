/// Player-selected challenge level, chosen at level select and threaded
/// through to the AI director's aggression and to per-tower-type build
/// limits (see `BoomspireGame.buildLimitFor`).
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

  /// Max simultaneous Laser Lances the player may have standing at once -
  /// it hits every domain at a very high fire rate, so it's rationed, and
  /// harder difficulties ration it further.
  int get laserTowerLimit => switch (this) {
    GameDifficulty.easy => 3,
    GameDifficulty.normal => 2,
    GameDifficulty.hard => 1,
  };
}
