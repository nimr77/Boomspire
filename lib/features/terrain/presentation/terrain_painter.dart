import 'dart:math';
import 'dart:ui' as ui;

import '../../../core/pathfinding/grid.dart';
import '../domain/models/biome.dart';
import '../domain/models/obstacle_kind.dart';
import '../domain/models/terrain_map.dart';

/// Pure procedural terrain rendering, shared by the in-game [TerrainComponent]
/// (baked once to a full-size cached image) and the level-select biome
/// preview thumbnails (painted small, live, via [CustomPainter]).
class TerrainPainter {
  const TerrainPainter._();

  static void paint(ui.Canvas canvas, ui.Size size, TerrainMap terrainMap) {
    final rect = ui.Offset.zero & size;
    final grid = terrainMap.grid;
    final kinds = terrainMap.obstacleKinds;
    final palette = terrainMap.biome.palette;

    canvas.drawRect(
      rect,
      ui.Paint()
        ..shader = ui.Gradient.linear(
          const ui.Offset(0, 0),
          ui.Offset(0, size.height),
          [palette.groundTop, palette.groundMid, palette.groundBottom],
          const [0.0, 0.5, 1.0],
        ),
    );

    final rnd = Random(42);
    for (var i = 0; i < 260; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final r = 14 + rnd.nextDouble() * 40;
      final shade = 0.15 + rnd.nextDouble() * 0.25;
      final color = ui.Color.lerp(
        palette.groundBottom,
        palette.groundMid,
        shade,
      )!.withValues(alpha: 0.3);
      canvas.drawCircle(
        ui.Offset(x, y),
        r,
        ui.Paint()
          ..color = color
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 14),
      );
    }
    // Fine speckle/fleck layer - small crisp dots (grass blades, pebbles,
    // sand grains) so the ground reads as a detailed painted tile instead
    // of a flat gradient, RA2-style.
    for (var i = 0; i < 900; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final light = rnd.nextBool();
      final color = (light ? palette.ridgeLight : palette.groundBottom)
          .withValues(alpha: 0.12 + rnd.nextDouble() * 0.1);
      canvas.drawRect(
        ui.Rect.fromCenter(
          center: ui.Offset(x, y),
          width: 1.5 + rnd.nextDouble() * 1.5,
          height: 1.5 + rnd.nextDouble() * 1.5,
        ),
        ui.Paint()..color = color,
      );
    }

    // Rivers/valleys are drawn as one continuous winding ribbon (instead of
    // independent per-cell tiles) so they read as a real, connected feature
    // rather than a stack of disjoint blocks. The river's banks/bed are
    // baked here (static); the flowing-water shimmer is drawn live on top
    // every frame instead - see [paintRiverFlow].
    final riverPoints = _obstaclePathPoints(
      grid,
      kinds,
      ObstacleKind.river,
      size.height,
    );
    if (riverPoints.length >= 2) {
      _paintRiverBed(canvas, _smoothPath(riverPoints), grid.cellSize);
    }
    final valleyPoints = _obstaclePathPoints(
      grid,
      kinds,
      ObstacleKind.valley,
      size.height,
    );
    if (valleyPoints.length >= 2) {
      _paintValleyPath(canvas, _smoothPath(valleyPoints), grid.cellSize);
    }

    // Pseudo-3D contact shadow pass: every mountain/dune cell drops a soft
    // dark shadow offset down-right (fake sun direction) before the shape
    // itself is painted, giving the ridge/dune a sense of elevation.
    for (var row = 0; row < grid.rows; row++) {
      for (var col = 0; col < grid.cols; col++) {
        final kind = kinds[row][col];
        if (kind != ObstacleKind.mountain && kind != ObstacleKind.dune) {
          continue;
        }
        final cx = col * grid.cellSize + grid.cellSize / 2;
        final cy = row * grid.cellSize + grid.cellSize / 2;
        canvas.drawCircle(
          ui.Offset(cx + 5, cy + 8),
          grid.cellSize * 0.42,
          ui.Paint()
            ..color = const ui.Color(0xFF000000).withValues(alpha: 0.28)
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
        );
      }
    }

    for (var row = 0; row < grid.rows; row++) {
      for (var col = 0; col < grid.cols; col++) {
        switch (kinds[row][col]) {
          case ObstacleKind.mountain:
            _paintMountain(canvas, grid, col, row, palette);
          case ObstacleKind.dune:
            _paintDune(canvas, grid, col, row, palette);
          case ObstacleKind.river:
          case ObstacleKind.valley:
            break; // already painted as a continuous ribbon above
          case null:
            if (palette.hasTrees && rnd.nextDouble() < 0.05) {
              _paintTree(canvas, grid, col, row, rnd);
            }
        }
      }
    }
  }

  /// One centerline point per row that contains [kind] cells (averaging
  /// their column if a row has more than one, e.g. a 2-wide crossing), plus
  /// synthetic points extending straight to the top/bottom canvas edges so
  /// the ribbon doesn't visibly stop short of the border.
  static List<ui.Offset> _obstaclePathPoints(
    Grid grid,
    List<List<ObstacleKind?>> kinds,
    ObstacleKind kind,
    double canvasHeight,
  ) {
    final points = <ui.Offset>[];
    for (var row = 0; row < grid.rows; row++) {
      var sum = 0.0;
      var count = 0;
      for (var col = 0; col < grid.cols; col++) {
        if (kinds[row][col] == kind) {
          sum += col;
          count++;
        }
      }
      if (count == 0) continue;
      final avgCol = sum / count;
      points.add(
        ui.Offset(
          avgCol * grid.cellSize + grid.cellSize / 2,
          row * grid.cellSize + grid.cellSize / 2,
        ),
      );
    }
    if (points.isEmpty) return points;
    return [
      ui.Offset(points.first.dx, 0),
      ...points,
      ui.Offset(points.last.dx, canvasHeight),
    ];
  }

  static void _paintDune(
    ui.Canvas canvas,
    Grid grid,
    int col,
    int row,
    BiomePalette palette,
  ) {
    final cx = col * grid.cellSize + grid.cellSize / 2;
    final cy = row * grid.cellSize + grid.cellSize / 2;
    final half = grid.cellSize / 2;

    final path = ui.Path()
      ..moveTo(cx - half * 0.95, cy + half * 0.75)
      ..quadraticBezierTo(
        cx - half * 0.2,
        cy - half * 0.85,
        cx,
        cy - half * 0.55,
      )
      ..quadraticBezierTo(
        cx + half * 0.5,
        cy - half * 0.3,
        cx + half * 0.95,
        cy + half * 0.75,
      )
      ..close();

    canvas.drawPath(
      path,
      ui.Paint()
        ..shader = ui.Gradient.linear(
          ui.Offset(cx, cy - half),
          ui.Offset(cx, cy + half),
          [palette.ridgeLight, palette.ridgeDark],
        ),
    );
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const ui.Color(0xFF5c3d1a).withValues(alpha: 0.5),
    );
  }

  static void _paintMountain(
    ui.Canvas canvas,
    Grid grid,
    int col,
    int row,
    BiomePalette palette,
  ) {
    final cx = col * grid.cellSize + grid.cellSize / 2;
    final cy = row * grid.cellSize + grid.cellSize / 2;
    final half = grid.cellSize / 2;
    // Seeded per-cell (not per-frame) so the jitter/texture is stable
    // across rebuilds instead of re-randomizing every bake.
    final rnd = Random(col * 92821 + row * 68917 + 1);
    double j() => (rnd.nextDouble() - 0.5) * half * 0.22;

    final path = ui.Path()
      ..moveTo(cx + j(), cy - half * 1.05 + j())
      ..lineTo(cx + half * 0.95 + j(), cy + half * 0.85 + j())
      ..lineTo(cx - half * 0.95 + j(), cy + half * 0.85 + j())
      ..close();

    // Soft, wide, blurred underlay so the peak's silhouette melts into the
    // surrounding ground texture instead of reading as a pasted-on sticker
    // shape - this is the main "on the terrain, not a shape" fix.
    canvas.drawPath(
      path,
      ui.Paint()
        ..color = palette.ridgeDark.withValues(alpha: 0.5)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8),
    );

    canvas.drawShadow(path, const ui.Color(0xFF000000), 3, false);
    canvas.drawPath(
      path,
      ui.Paint()
        ..shader = ui.Gradient.linear(
          ui.Offset(cx, cy - half),
          ui.Offset(cx, cy + half),
          [palette.ridgeLight, palette.ridgeDark],
        ),
    );

    // Rocky texture dabs clipped to the silhouette so the face reads as a
    // painted rock surface instead of a flat gradient fill.
    for (var i = 0; i < 12; i++) {
      final px = cx + (rnd.nextDouble() - 0.5) * half * 1.6;
      final py = cy - half * 0.7 + rnd.nextDouble() * half * 1.5;
      if (!path.contains(ui.Offset(px, py))) continue;
      canvas.drawCircle(
        ui.Offset(px, py),
        1.2 + rnd.nextDouble() * 2.2,
        ui.Paint()
          ..color = (rnd.nextBool() ? palette.ridgeLight : palette.ridgeDark)
              .withValues(alpha: 0.24),
      );
    }

    final snowCap = ui.Path()
      ..moveTo(cx + j(), cy - half * 1.05)
      ..lineTo(cx + half * 0.4, cy - half * 0.2)
      ..lineTo(cx - half * 0.4, cy - half * 0.2)
      ..close();
    canvas.drawPath(
      snowCap,
      ui.Paint()
        ..color = palette.capColor.withValues(alpha: 0.78)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.2),
    );
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const ui.Color(0xFF1c2126).withValues(alpha: 0.4),
    );
  }

  /// Static shore/bed/water-gradient layers only - baked once into the
  /// cached terrain image. The moving shimmer/ripples are drawn separately
  /// every frame by [paintRiverFlow] so the river reads as flowing water.
  static void _paintRiverBed(ui.Canvas canvas, ui.Path path, double cellSize) {
    final bounds = path.getBounds();
    // Sandy shore first, wider than the water itself.
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..strokeWidth = cellSize * 2.0
        ..color = const ui.Color(0xFFd8c48a).withValues(alpha: 0.55),
    );
    // Wet, darker sand right at the waterline.
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..strokeWidth = cellSize * 1.5
        ..color = const ui.Color(0xFF9c8256).withValues(alpha: 0.6),
    );
    // Water body with a deep-to-mid gradient across its width.
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..strokeWidth = cellSize * 1.3
        ..shader = ui.Gradient.linear(
          bounds.topCenter,
          bounds.bottomCenter,
          const [
            ui.Color(0xFF0a3450),
            ui.Color(0xFF1f7fa8),
            ui.Color(0xFF0a3450),
            ui.Color(0xFF1f7fa8),
            ui.Color(0xFF0a3450),
          ],
          const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
    );
  }

  /// Live per-frame animated overlay for a river: a scrolling specular
  /// dash streak plus ripple arcs that both drift downstream as [phase]
  /// (elapsed seconds) advances, on top of the static [_paintRiverBed].
  static void paintRiverFlow(
    ui.Canvas canvas,
    ui.Path path,
    double cellSize,
    double phase,
  ) {
    final metric = path.computeMetrics().firstOrNull;
    if (metric == null) return;
    final length = metric.length;
    if (length <= 0) return;

    const dashLen = 30.0;
    const gapLen = 26.0;
    const period = dashLen + gapLen;
    final flowOffset = (phase * 70) % period;
    final highlightPaint = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..strokeWidth = cellSize * 0.32
      ..color = const ui.Color(0xFFbfeeff).withValues(alpha: 0.45);
    for (var dist = -flowOffset; dist < length; dist += period) {
      final start = dist.clamp(0.0, length);
      final end = (dist + dashLen).clamp(0.0, length);
      if (end <= start) continue;
      final sub = metric
          .extractPath(start, end)
          .shift(const ui.Offset(-4, -3));
      canvas.drawPath(sub, highlightPaint);
    }

    final rippleCount = (length / (cellSize * 1.4)).floor().clamp(0, 200);
    if (rippleCount == 0) return;
    final rnd = Random(7);
    final ripplePaint = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const ui.Color(0xFFe8fbff).withValues(alpha: 0.3);
    final step = length / rippleCount;
    for (var i = 0; i < rippleCount; i++) {
      final jitter = (rnd.nextDouble() - 0.5) * cellSize * 0.5;
      final dist = ((i + 0.5) * step + phase * 40) % length;
      final tangent = metric.getTangentForOffset(dist);
      if (tangent == null) continue;
      final normal = ui.Offset(-tangent.vector.dy, tangent.vector.dx);
      final center = tangent.position + normal * jitter;
      canvas.drawArc(
        ui.Rect.fromCenter(
          center: center,
          width: cellSize * 0.5,
          height: cellSize * 0.22,
        ),
        0,
        pi,
        false,
        ripplePaint,
      );
    }
  }

  /// Centerline points for the river obstacle in [terrainMap], smoothed
  /// into a [ui.Path] - null if this map has no river (e.g. desert biome,
  /// which uses a dry valley instead). Used both to bake the static bed
  /// (see [_paintRiverBed]) and to drive the live [paintRiverFlow] overlay.
  static ui.Path? riverPath(TerrainMap terrainMap, double canvasHeight) {
    final points = _obstaclePathPoints(
      terrainMap.grid,
      terrainMap.obstacleKinds,
      ObstacleKind.river,
      canvasHeight,
    );
    if (points.length < 2) return null;
    return _smoothPath(points);
  }

  static void _paintTree(
    ui.Canvas canvas,
    Grid grid,
    int col,
    int row,
    Random rnd,
  ) {
    final cx =
        col * grid.cellSize + grid.cellSize / 2 + (rnd.nextDouble() - 0.5) * 8;
    final cy =
        row * grid.cellSize + grid.cellSize / 2 + (rnd.nextDouble() - 0.5) * 8;
    final scale = 0.7 + rnd.nextDouble() * 0.5;

    // Ground shadow first, so the canopy reads as sitting above the tile.
    canvas.drawOval(
      ui.Rect.fromCenter(
        center: ui.Offset(cx + 3, cy + 9 * scale),
        width: 20 * scale,
        height: 8 * scale,
      ),
      ui.Paint()
        ..color = const ui.Color(0xFF000000).withValues(alpha: 0.22)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3),
    );
    canvas.drawRect(
      ui.Rect.fromCenter(
        center: ui.Offset(cx, cy + 8 * scale),
        width: 3 * scale,
        height: 8 * scale,
      ),
      ui.Paint()..color = const ui.Color(0xFF4a3421),
    );

    // Rounded, overlapping foliage blobs instead of flat pine tiers - a
    // cluster of clumps reads as a top-down tree canopy, RA2-style.
    const lobes = [
      (dx: 0.0, dy: -2.0, scale: 1.0),
      (dx: -6.0, dy: 2.0, scale: 0.75),
      (dx: 6.0, dy: 2.0, scale: 0.8),
      (dx: 0.0, dy: 5.0, scale: 0.85),
    ];
    for (final lobe in lobes) {
      final lobeCenter = ui.Offset(
        cx + lobe.dx * scale,
        cy + lobe.dy * scale - 4 * scale,
      );
      final radius = 9 * scale * lobe.scale;
      canvas.drawCircle(
        lobeCenter,
        radius,
        ui.Paint()..color = const ui.Color(0xFF1f3d22).withValues(alpha: 0.92),
      );
    }
    // Single highlight blob (fake sun from top-left) so the canopy isn't
    // one flat silhouette.
    canvas.drawCircle(
      ui.Offset(cx - 5 * scale, cy - 8 * scale),
      6 * scale,
      ui.Paint()..color = const ui.Color(0xFF3f6b3f).withValues(alpha: 0.6),
    );
  }

  static void _paintValleyPath(
    ui.Canvas canvas,
    ui.Path path,
    double cellSize,
  ) {
    final bounds = path.getBounds();
    // Sunlit cliff rim, wider than the canyon floor.
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..strokeWidth = cellSize * 2.0
        ..color = const ui.Color(0xFFcf9a5c).withValues(alpha: 0.55),
    );
    // Canyon floor with a subtle vertical gradient for depth.
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..strokeWidth = cellSize * 1.4
        ..shader = ui.Gradient.linear(
          bounds.topCenter,
          bounds.bottomCenter,
          const [
            ui.Color(0xFF4a3016),
            ui.Color(0xFF241608),
            ui.Color(0xFF4a3016),
          ],
          const [0.0, 0.5, 1.0],
        ),
    );
    // Dark crack/erosion detail streak down the middle.
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = ui.StrokeCap.round
        ..strokeWidth = cellSize * 0.25
        ..color = const ui.Color(0xFF120a04).withValues(alpha: 0.5),
    );

    final metric = path.computeMetrics().firstOrNull;
    if (metric != null) {
      final rnd = Random(11);
      final rockCount = (metric.length / (cellSize * 1.1)).floor();
      for (var i = 0; i < rockCount; i++) {
        final dist = (i + 0.5) * (metric.length / rockCount);
        final tangent = metric.getTangentForOffset(dist);
        if (tangent == null) continue;
        final normal = ui.Offset(-tangent.vector.dy, tangent.vector.dx);
        final offset = (rnd.nextDouble() - 0.5) * cellSize * 0.7;
        final center = tangent.position + normal * offset;
        canvas.drawCircle(
          center,
          2 + rnd.nextDouble() * 2.5,
          ui.Paint()..color = const ui.Color(0xFF6b4321).withValues(alpha: 0.5),
        );
      }
    }
  }

  /// Smooths a polyline into a curved [ui.Path] by quadratic-bezier-ing
  /// through the midpoint of every consecutive pair - a cheap way to avoid
  /// sharp zig-zag joints between per-row samples.
  static ui.Path _smoothPath(List<ui.Offset> points) {
    final path = ui.Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = ui.Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }
}
