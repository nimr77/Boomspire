import 'dart:math';

/// Orders a connected group of cells into a single spatially-coherent
/// chain: starts from the lowest-degree cell (a true endpoint for a
/// snake-shaped stroke, or an arbitrary cell for a closed loop/blob), then
/// greedily walks to the nearest not-yet-visited cell.
List<Point<int>> chainCells(List<Point<int>> cells) {
  if (cells.length <= 2) return cells;
  final set = cells.toSet();
  int neighborCount(Point<int> c) {
    var count = 0;
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        if (set.contains(Point(c.x + dx, c.y + dy))) count++;
      }
    }
    return count;
  }

  var start = cells.first;
  var bestDegree = 9;
  for (final c in cells) {
    final degree = neighborCount(c);
    if (degree < bestDegree) {
      bestDegree = degree;
      start = c;
    }
  }

  final remaining = {...cells}..remove(start);
  final chain = <Point<int>>[start];
  var current = start;
  while (remaining.isNotEmpty) {
    Point<int>? nearest;
    var nearestDistSq = 0;
    for (final c in remaining) {
      final dx = c.x - current.x;
      final dy = c.y - current.y;
      final distSq = dx * dx + dy * dy;
      if (nearest == null || distSq < nearestDistSq) {
        nearest = c;
        nearestDistSq = distSq;
      }
    }
    chain.add(nearest!);
    remaining.remove(nearest);
    current = nearest;
  }
  return chain;
}
