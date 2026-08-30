import 'package:flame/game.dart' show Vector2;
import 'package:flutter/foundation.dart' show compute;

import '../../../core/pathfinding/grid.dart';
import '../../terrain/domain/models/biome.dart';
import '../../terrain/domain/models/obstacle_kind.dart';
import '../domain/models/editor_terrain_preview.dart';
import '../domain/models/map_draft.dart';
import '../domain/models/water_path.dart';

const _cellSize = 40.0;

double _distanceToSegment(Vector2 p, Vector2 a, Vector2 b) {
  final ab = b - a;
  final lengthSquared = ab.length2;
  final t = lengthSquared == 0
      ? 0.0
      : (((p - a).dot(ab)) / lengthSquared).clamp(0.0, 1.0);
  final closest = a + ab * t;
  return p.distanceTo(closest);
}

EditorTerrainPreview _generatePreview(MapDraft draft) {
  final cols = (draft.arenaWidth / _cellSize).round().clamp(4, 4096);
  final rows = (draft.arenaHeight / _cellSize).round().clamp(4, 4096);
  final grid = Grid(cols: cols, rows: rows, cellSize: _cellSize);
  final obstacleKinds = List.generate(
    rows,
    (_) => List<ObstacleKind?>.filled(cols, null),
  );
  final variants = List.generate(rows, (_) => List<Biome?>.filled(cols, null));

  void paint(int col, int row, ObstacleKind kind, Biome? variant) {
    if (!grid.inBounds(col, row)) return;
    grid.setMountain(col, row, true);
    obstacleKinds[row][col] = kind;
    variants[row][col] = variant;
  }

  for (final cell in draft.paintedCells) {
    paint(cell.col, cell.row, cell.kind, cell.variant);
  }

  for (final path in draft.waterPaths) {
    _rasterizeWaterPath(path, cols, rows, paint);
  }

  // Same as painted obstacles above: a null variant just renders with
  // this map's own biome, a set one overrides it - no extra toggle needed.
  for (final tree in draft.treeCells) {
    final variant = tree.variant;
    if (variant == null) continue;
    if (!grid.inBounds(tree.col, tree.row)) continue;
    variants[tree.row][tree.col] = variant;
  }

  return EditorTerrainPreview(
    grid: grid,
    obstacleKinds: obstacleKinds,
    variants: variants,
    biome: draft.biome,
  );
}

bool _pointInPolygon(Vector2 p, List<Vector2> polygon) {
  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final vi = polygon[i];
    final vj = polygon[j];
    final crosses = (vi.y > p.y) != (vj.y > p.y);
    if (crosses && p.x < (vj.x - vi.x) * (p.y - vi.y) / (vj.y - vi.y) + vi.x) {
      inside = !inside;
    }
  }
  return inside;
}

void _rasterizeWaterPath(
  WaterPath path,
  int cols,
  int rows,
  void Function(int col, int row, ObstacleKind kind, Biome? variant) paint,
) {
  if (path.points.length < 2) return;
  final points = path.points
      .map((p) => Vector2(p.x, p.y))
      .toList(growable: false);

  switch (path.kind) {
    case WaterFeatureKind.river:
    case WaterFeatureKind.lava:
      final kind = path.kind == WaterFeatureKind.lava
          ? ObstacleKind.lava
          : ObstacleKind.river;
      final halfWidth = path.width / 2;
      for (var col = 0; col < cols; col++) {
        for (var row = 0; row < rows; row++) {
          final center = Vector2(
            col * _cellSize + _cellSize / 2,
            row * _cellSize + _cellSize / 2,
          );
          for (var i = 0; i < points.length - 1; i++) {
            if (_distanceToSegment(center, points[i], points[i + 1]) <=
                halfWidth) {
              paint(col, row, kind, path.variant);
              break;
            }
          }
        }
      }
    case WaterFeatureKind.lake:
    case WaterFeatureKind.volcanicLake:
      final kind = path.kind == WaterFeatureKind.volcanicLake
          ? ObstacleKind.volcanicLake
          : ObstacleKind.lake;
      for (var col = 0; col < cols; col++) {
        for (var row = 0; row < rows; row++) {
          final center = Vector2(
            col * _cellSize + _cellSize / 2,
            row * _cellSize + _cellSize / 2,
          );
          if (_pointInPolygon(center, points)) {
            paint(col, row, kind, path.variant);
          }
        }
      }
  }
}

/// Rasterizes a hand-drawn [MapDraft] into an [EditorTerrainPreview]. The
/// grid/geometry work runs off the UI thread via [compute] (a background
/// isolate) so painting a large map never janks the editor canvas.
class EditorTerrainGenerator {
  Future<EditorTerrainPreview> generate(MapDraft draft) =>
      compute(_generatePreview, draft);
}
