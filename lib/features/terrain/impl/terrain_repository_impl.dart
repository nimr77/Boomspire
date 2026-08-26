import 'dart:math';

import '../../game_core/domain/models/game_config.dart';
import '../domain/models/build_slot.dart';
import '../domain/models/terrain_map.dart';
import '../domain/repos/terrain_repository.dart';

/// Builds the mountain-pass map: a zig-zagging path carved through the peaks,
/// with build pads procedurally placed alongside each path segment.
class TerrainRepositoryImpl implements TerrainRepository {
  static const arenaWidth = GameConfig.arenaWidth;
  static const arenaHeight = GameConfig.arenaHeight;

  static const List<PathPoint> _waypoints = [
    PathPoint(-60, 620),
    PathPoint(260, 620),
    PathPoint(260, 420),
    PathPoint(620, 420),
    PathPoint(620, 180),
    PathPoint(980, 180),
    PathPoint(980, 560),
    PathPoint(1340, 560),
  ];

  @override
  TerrainMap loadTerrain() {
    return TerrainMap(
      arenaWidth: arenaWidth,
      arenaHeight: arenaHeight,
      waypoints: _waypoints,
      buildSlots: _computeBuildSlots(),
    );
  }

  List<BuildSlot> _computeBuildSlots() {
    const slotSize = 64.0;
    const offset = 130.0;
    const margin = 50.0;
    const minSeparation = 100.0;

    final centers = <Point<double>>[];
    var id = 0;
    final slots = <BuildSlot>[];

    for (var i = 0; i < _waypoints.length - 1; i++) {
      final a = _waypoints[i];
      final b = _waypoints[i + 1];
      final dx = b.x - a.x;
      final dy = b.y - a.y;
      final length = sqrt(dx * dx + dy * dy);
      if (length < 40) continue;

      final dirX = dx / length;
      final dirY = dy / length;
      // Perpendicular direction.
      final perpX = -dirY;
      final perpY = dirX;

      final midX = a.x + dirX * (length / 2);
      final midY = a.y + dirY * (length / 2);

      for (final side in [-1.0, 1.0]) {
        final cx = midX + perpX * offset * side;
        final cy = midY + perpY * offset * side;

        final withinArena = cx >= margin &&
            cx <= arenaWidth - margin &&
            cy >= margin &&
            cy <= arenaHeight - margin;
        if (!withinArena) continue;

        final tooClose = centers.any(
          (p) => sqrt(pow(p.x - cx, 2) + pow(p.y - cy, 2)) < minSeparation,
        );
        if (tooClose) continue;

        centers.add(Point(cx, cy));
        slots.add(BuildSlot(id: id++, x: cx, y: cy, size: slotSize));
      }
    }
    return slots;
  }
}
