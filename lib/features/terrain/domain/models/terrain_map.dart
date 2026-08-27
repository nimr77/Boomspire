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

  /// Every point enemies may spawn from - a scene can define more than one
  /// so attacks come from multiple directions (or even every edge).
  final List<PathPoint> spawnPoints;
  final PathPoint basePoint;

  /// The AI opponent's base, for a [GameMode.skirmish] scene - null for a
  /// [GameMode.waveDefense] scene, which only ever has the one [basePoint].
  final PathPoint? secondaryBasePoint;

  /// Capturable second-resource node positions (see
  /// `GameScene.resourceNodeSites`) - empty for scenes with no capturable
  /// economy.
  final List<PathPoint> resourceNodePoints;
  const TerrainMap({
    required this.arenaWidth,
    required this.arenaHeight,
    required this.grid,
    required this.biome,
    required this.obstacleKinds,
    required this.spawnPoints,
    required this.basePoint,
    this.secondaryBasePoint,
    this.resourceNodePoints = const [],
  });
}
