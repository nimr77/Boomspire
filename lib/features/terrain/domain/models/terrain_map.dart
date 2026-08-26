import '../../../../core/pathfinding/grid.dart';

/// A single point in world coordinates (spawn/base markers, path nodes).
class PathPoint {
  const PathPoint(this.x, this.y);

  final double x;
  final double y;
}

/// Immutable description of the playable arena: its size, the mountain
/// obstruction grid (also used for enemy pathfinding), and the spawn/base
/// anchor points. Every non-mountain cell is buildable.
class TerrainMap {
  const TerrainMap({
    required this.arenaWidth,
    required this.arenaHeight,
    required this.grid,
    required this.spawnPoint,
    required this.basePoint,
  });

  final double arenaWidth;
  final double arenaHeight;
  final Grid grid;
  final PathPoint spawnPoint;
  final PathPoint basePoint;
}
