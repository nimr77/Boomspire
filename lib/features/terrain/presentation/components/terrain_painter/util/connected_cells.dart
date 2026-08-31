import 'dart:math';

import '../../../../../../core/pathfinding/grid.dart';
import '../../../../domain/models/obstacle_kind.dart';

/// Flood-fills [kinds] (8-directional) into groups of adjacent cells that
/// all match [kind].
List<List<Point<int>>> connectedCells(
  Grid grid,
  List<List<ObstacleKind?>> kinds,
  ObstacleKind kind,
) {
  final visited = List.generate(
    grid.rows,
    (_) => List<bool>.filled(grid.cols, false),
  );
  final components = <List<Point<int>>>[];
  for (var row = 0; row < grid.rows; row++) {
    for (var col = 0; col < grid.cols; col++) {
      if (visited[row][col] || kinds[row][col] != kind) continue;
      final component = <Point<int>>[];
      final queue = <Point<int>>[Point(col, row)];
      visited[row][col] = true;
      var head = 0;
      while (head < queue.length) {
        final cell = queue[head++];
        component.add(cell);
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            final nx = cell.x + dx;
            final ny = cell.y + dy;
            if (nx < 0 || ny < 0 || nx >= grid.cols || ny >= grid.rows) {
              continue;
            }
            if (visited[ny][nx] || kinds[ny][nx] != kind) continue;
            visited[ny][nx] = true;
            queue.add(Point(nx, ny));
          }
        }
      }
      components.add(component);
    }
  }
  return components;
}
