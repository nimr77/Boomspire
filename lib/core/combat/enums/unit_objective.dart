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

  /// Beeline for the opposing team's home base and keep fighting whatever's
  /// in range along the way (including the base itself, once close enough) -
  /// used by both sides' units in a [GameMode.skirmish] match instead of
  /// [rushBase]/[huntHostiles], since a skirmish base is a real destructible
  /// target rather than something to escape past or something a unit only
  /// stumbles into while hunting. Never banks a kill/escape bounty and never
  /// forces a spawn-point starting position, unlike [rushBase].
  assaultBase,

  /// Head for and hold at a fixed world point (see
  /// `MobileUnitComponent.captureTarget`) - a vehicle sent to claim a
  /// `ResourceNodeComponent`. Still fights anything that gets in range
  /// along the way/while holding, same as [assaultBase]; never banks a
  /// kill/escape bounty.
  captureNode,
}
