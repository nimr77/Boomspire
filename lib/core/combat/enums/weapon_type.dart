/// The kind of ordnance a mobile unit fires at whatever it's engaging -
/// drives which projectile/effect `MobileUnitComponent` spawns. Shared by
/// both enemy and ally units so the same weapon variety is available to
/// either side.
enum WeaponType {
  /// Fast straight-line tracer round (infantry rifles).
  bullet,

  /// Heavier single shell with a modest splash radius (armor/support fire).
  cannon,

  /// Slower homing projectile with a smoke trail and a bigger splash.
  rocket,

  /// Instant-hit beam - damage applies the moment it's fired.
  laser,
}
