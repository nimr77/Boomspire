import 'dart:collection';
import 'dart:math';

import 'grid.dart';

/// Classic A* search over a [Grid], 8-directional, used so ground enemies can
/// walk anywhere on the terrain while routing around mountains and towers.
class AStarPathFinder {
  static List<Point<int>>? findPath(
    Grid grid,
    Point<int> start,
    Point<int> goal,
  ) {
    if (grid.isBlocked(goal.x, goal.y)) return null;

    final open = HashSet<Point<int>>()..add(start);
    final cameFrom = <Point<int>, Point<int>>{};
    final gScore = <Point<int>, double>{start: 0};
    final fScore = <Point<int>, double>{start: _heuristic(start, goal)};

    final frontier = PriorityQueue<Point<int>>(
      (a, b) => (fScore[a] ?? double.infinity).compareTo(
        fScore[b] ?? double.infinity,
      ),
    )..add(start);

    var iterations = 0;
    while (frontier.isNotEmpty && iterations++ < 4000) {
      final current = frontier.removeFirst();
      if (!open.contains(current)) continue;
      open.remove(current);

      if (current == goal) return _reconstruct(cameFrom, current);

      for (final neighbor in grid.neighbors8(current)) {
        if (grid.isBlocked(neighbor.x, neighbor.y)) continue;
        // Prevent cutting across diagonal mountain corners.
        if (neighbor.x != current.x && neighbor.y != current.y) {
          if (grid.isBlocked(neighbor.x, current.y) ||
              grid.isBlocked(current.x, neighbor.y)) {
            continue;
          }
        }
        final stepCost = (neighbor.x != current.x && neighbor.y != current.y)
            ? 1.4142
            : 1.0;
        final tentativeG = (gScore[current] ?? double.infinity) + stepCost;
        if (tentativeG < (gScore[neighbor] ?? double.infinity)) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeG;
          fScore[neighbor] = tentativeG + _heuristic(neighbor, goal);
          if (!open.contains(neighbor)) {
            open.add(neighbor);
            frontier.add(neighbor);
          }
        }
      }
    }
    return null;
  }

  static double _heuristic(Point<int> a, Point<int> b) =>
      sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));

  static List<Point<int>> _reconstruct(
    Map<Point<int>, Point<int>> cameFrom,
    Point<int> current,
  ) {
    final path = [current];
    var c = current;
    while (cameFrom.containsKey(c)) {
      c = cameFrom[c]!;
      path.add(c);
    }
    return path.reversed.toList();
  }
}

/// Minimal binary-heap priority queue (avoids pulling in a package dep).
class PriorityQueue<E> {
  PriorityQueue(this._compare);

  final Comparator<E> _compare;
  final List<E> _heap = [];

  bool get isNotEmpty => _heap.isNotEmpty;

  void add(E value) {
    _heap.add(value);
    _bubbleUp(_heap.length - 1);
  }

  E removeFirst() {
    final top = _heap.first;
    final last = _heap.removeLast();
    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _bubbleDown(0);
    }
    return top;
  }

  void _bubbleUp(int index) {
    while (index > 0) {
      final parent = (index - 1) ~/ 2;
      if (_compare(_heap[index], _heap[parent]) >= 0) break;
      _swap(index, parent);
      index = parent;
    }
  }

  void _bubbleDown(int index) {
    final length = _heap.length;
    while (true) {
      final left = index * 2 + 1;
      final right = index * 2 + 2;
      var smallest = index;
      if (left < length && _compare(_heap[left], _heap[smallest]) < 0) {
        smallest = left;
      }
      if (right < length && _compare(_heap[right], _heap[smallest]) < 0) {
        smallest = right;
      }
      if (smallest == index) break;
      _swap(index, smallest);
      index = smallest;
    }
  }

  void _swap(int a, int b) {
    final tmp = _heap[a];
    _heap[a] = _heap[b];
    _heap[b] = tmp;
  }
}
