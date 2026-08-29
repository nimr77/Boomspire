/// Visual/gameplay flavor of an impassable cell. All kinds behave the same
/// for pathfinding (fully blocked to ground units, ignored entirely by air
/// units) - this only drives which paint routine [TerrainComponent] uses
/// for a given blocked cell. [lava] is a molten, river-shaped crossing;
/// [volcanicLake] is its lake-shaped counterpart.
enum ObstacleKind { mountain, dune, river, valley, lake, lava, volcanicLake }
