/// Which towers enemies should prioritize this wave, as decided by the AI
/// director (or the local fallback heuristic). `clearObstacles` makes
/// enemies detour and prioritize destroying any tower blocking their path
/// to the base (rather than just the nearest/weakest one), widening their
/// detection range so they'll go out of their way to do it.
enum FocusHint { nearestTower, weakestTower, rushBase, clearObstacles }
