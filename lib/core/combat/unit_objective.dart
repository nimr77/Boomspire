/// What a mobile unit does once nothing is in weapons range right now -
/// takes the place of the old `EnemyComponent`/`AllyUnitComponent` class
/// split, so any team's units can follow either strategy instead of "enemy"
/// and "ally" being two hardcoded, mutually exclusive behaviors.
enum UnitObjective {
  /// Beeline for the opposing team's home base; escaping past it damages
  /// that team and banks a kill/escape bounty. Used by invader-style teams
  /// in a waves scene.
  rushBase,

  /// Hunt down the nearest hostile unit (or structure) and hold position
  /// once nothing hostile is left - used by player/ally-built units.
  huntHostiles,
}
