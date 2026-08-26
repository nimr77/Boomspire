import 'dart:math';

import 'package:flame/game.dart';

/// A uniform grid over the arena used for both build-placement legality and
/// enemy pathfinding. A cell is "blocked" if it's impassable mountain terrain
/// or currently occupied by a tower.
class Grid {
  Grid({required this.cols, required this.rows, required this.cellSize})
    : blocked = List.generate(rows, (_) => List.filled(cols, false)),
      mountain = List.generate(rows, (_) => List.filled(cols, false));

  final int cols;
  final int rows;
  final double cellSize;

  /// Static terrain obstruction (mountains) - never changes at runtime.
  final List<List<bool>> mountain;

  /// Combined obstruction (mountain OR tower) used for pathfinding/placement.
  final List<List<bool>> blocked;

  bool inBounds(int col, int row) =>
      col >= 0 && col < cols && row >= 0 && row < rows;

  Point<int> worldToCell(Vector2 world) => Point(
    (world.x / cellSize).floor().clamp(0, cols - 1),
    (world.y / cellSize).floor().clamp(0, rows - 1),
  );

  Vector2 cellCenter(Point<int> cell) => Vector2(
    cell.x * cellSize + cellSize / 2,
    cell.y * cellSize + cellSize / 2,
  );

  bool isBlocked(int col, int row) =>
      !inBounds(col, row) || blocked[row][col];

  void setTowerOccupied(int col, int row, bool occupied) {
    if (!inBounds(col, row)) return;
    blocked[row][col] = occupied || mountain[row][col];
  }

  void setMountain(int col, int row, bool isMountain) {
    if (!inBounds(col, row)) return;
    mountain[row][col] = isMountain;
    if (isMountain) blocked[row][col] = true;
  }

  /// Flood-fill reachability check, used to guarantee the map is solvable
  /// after mountains are carved.
  bool isReachable(Point<int> start, Point<int> goal) {
    if (isBlocked(start.x, start.y) || isBlocked(goal.x, goal.y)) return false;
    final visited = <Point<int>>{start};
    final queue = [start];
    while (queue.isNotEmpty) {
      final cur = queue.removeLast();
      if (cur == goal) return true;
      for (final n in neighbors4(cur)) {
        if (visited.contains(n) || isBlocked(n.x, n.y)) continue;
        visited.add(n);
        queue.add(n);
      }
    }
    return false;
  }

  List<Point<int>> neighbors4(Point<int> p) => [
    Point(p.x + 1, p.y),
    Point(p.x - 1, p.y),
    Point(p.x, p.y + 1),
    Point(p.x, p.y - 1),
  ];

  List<Point<int>> neighbors8(Point<int> p) => [
    ...neighbors4(p),
    Point(p.x + 1, p.y + 1),
    Point(p.x - 1, p.y + 1),
    Point(p.x + 1, p.y - 1),
    Point(p.x - 1, p.y - 1),
  ];
}
