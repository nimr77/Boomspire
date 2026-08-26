import '../../../../core/pathfinding/grid.dart';
import 'biome.dart';
import 'obstacle_kind.dart';

/// A single point in world coordinates (spawn/base markers, path nodes).
class PathPoint {
  final double x;

  final double y;
  const PathPoint(this.x, this.y);
}

/// Immutable description of the playable arena: its size, the mountain
/// obstruction grid (also used for enemy pathfinding), and the spawn/base
/// anchor points. Every non-mountain cell is buildable.
class TerrainMap {
  final double arenaWidth;

  final double arenaHeight;
  final Grid grid;
  final Biome biome;

  /// Per-cell obstacle flavor (null = open ground), same shape as [grid].
  final List<List<ObstacleKind?>> obstacleKinds;

  final PathPoint spawnPoint;
  final PathPoint basePoint;
  const TerrainMap({
    required this.arenaWidth,
    required this.arenaHeight,
    required this.grid,
    required this.biome,
    required this.obstacleKinds,
    required this.spawnPoint,
    required this.basePoint,
  });
}
