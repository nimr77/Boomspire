/// Visual/gameplay flavor of an impassable cell. All kinds behave the same
/// for pathfinding (fully blocked) - this only drives which paint routine
/// [TerrainComponent] uses for a given blocked cell.
enum ObstacleKind { mountain, dune, river, valley, lake }
