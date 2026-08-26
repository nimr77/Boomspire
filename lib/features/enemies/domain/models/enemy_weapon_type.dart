/// The kind of ordnance an enemy fires back at a tower while engaging it -
/// drives which projectile/effect [EnemyComponent] spawns in
/// `_maybeEngageTower()`.
enum EnemyWeaponType {
  /// Fast straight-line tracer round (infantry rifles).
  bullet,

  /// Heavier single shell with a modest splash radius (armor/support fire).
  cannon,

  /// Slower homing projectile with a smoke trail and a bigger splash.
  rocket,

  /// Instant-hit beam - damage applies the moment it's fired.
  laser,
}
