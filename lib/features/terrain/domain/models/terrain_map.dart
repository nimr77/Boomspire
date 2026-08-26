import 'build_slot.dart';

/// A single point along the enemy path, in world coordinates.
class PathPoint {
  const PathPoint(this.x, this.y);

  final double x;
  final double y;
}

/// Immutable description of the playable arena: its size, the mountain-pass
/// enemy route, and the buildable pads carved into the terrain.
class TerrainMap {
  const TerrainMap({
    required this.arenaWidth,
    required this.arenaHeight,
    required this.waypoints,
    required this.buildSlots,
  });

  final double arenaWidth;
  final double arenaHeight;
  final List<PathPoint> waypoints;
  final List<BuildSlot> buildSlots;
}
