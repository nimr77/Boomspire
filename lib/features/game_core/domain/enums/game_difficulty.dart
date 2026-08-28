/// Player-selected challenge level, chosen at level select and threaded
/// through to the AI director's aggression (see `BoomspireGame.buildLimitFor`
/// for the per-tower-type build limits, which are now flat rather than
/// difficulty-scaled).
enum GameDifficulty { easy, normal, hard }
