/// How an enemy's visual "idles" while it moves, layered on top of the
/// facing angle that pathfinding/flight already sets - keeps ground troops,
/// tracked vehicles, and aircraft from all sharing the exact same motion.
enum EnemyMovementStyle {
  /// Infantry: a gentle vertical bob, like footsteps.
  walk,

  /// Tracked/wheeled vehicles: a subtle side-to-side rock instead of a
  /// bob, like treads settling over uneven ground.
  roll,

  /// Helicopters: a slower, slightly larger bob (rotor-borne hover sway).
  hover,

  /// Fixed-wing aircraft: a lazy banking wobble as it "cuts through the
  /// air" at speed.
  swoop,
}
