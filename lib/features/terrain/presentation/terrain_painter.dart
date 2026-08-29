import 'dart:math';
import 'dart:ui' as ui;

import '../../../core/pathfinding/grid.dart';
import '../domain/models/biome.dart';
import '../domain/models/obstacle_kind.dart';
import '../domain/models/terrain_map.dart';
import '../extensions/biome_extensions.dart';

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

    // Rivers/valleys are drawn as one continuous winding ribbon per
    // connected group of cells (instead of independent per-cell tiles) so
    // they read as a real, connected feature rather than a stack of
    // disjoint blocks - this works for any hand-drawn shape (not just a
    // single top-to-bottom crossing), since the ordering is reconstructed
    // from actual cell adjacency rather than assumed. The river's
    // banks/bed are baked here (static); the flowing-water shimmer is
    // drawn live on top every frame instead - see [paintRiverFlow].
    for (final chain in _obstacleChains(
      grid,
      kinds,
      ObstacleKind.river,
      size.height,
    )) {
      if (chain.length >= 2) {
        _paintRiverBed(
          canvas,
          _smoothPath(chain),
          grid.cellSize,
          _chainBiome(terrainMap, grid, chain).palette,
        );
      }
    }
    for (final chain in _obstacleChains(
      grid,
      kinds,
      ObstacleKind.valley,
      size.height,
    )) {
      if (chain.length >= 2) {
        _paintValleyPath(canvas, _smoothPath(chain), grid.cellSize);
      }
    }
    // Lakes are area fills (not linear features) - each connected blob of
    // lake cells is unioned into one pond shape instead of ordered into a
    // ribbon.
    for (final component in _connectedCells(grid, kinds, ObstacleKind.lake)) {
      _paintLake(
        canvas,
        component,
        grid.cellSize,
        terrainMap.biomeAt(component.first.x, component.first.y).palette,
      );
    }

    // Lava/volcanic lakes are the molten counterparts of river/lake - a
    // fixed magma look regardless of biome, since molten rock doesn't get
    // a biome tint the way water/sand does.
    for (final chain in _obstacleChains(
      grid,
      kinds,
      ObstacleKind.lava,
      size.height,
    )) {
      if (chain.length >= 2) {
        _paintLavaBed(canvas, _smoothPath(chain), grid.cellSize);
      }
    }
    for (final component in _connectedCells(
      grid,
      kinds,
      ObstacleKind.volcanicLake,
    )) {
      _paintVolcanicLake(canvas, component, grid.cellSize);
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
            _paintMountain(
              canvas,
              grid,
              col,
              row,
              terrainMap.biomeAt(col, row).palette,
            );
          case ObstacleKind.dune:
            _paintDune(
              canvas,
              grid,
              col,
              row,
              terrainMap.biomeAt(col, row).palette,
            );
          case ObstacleKind.river:
          case ObstacleKind.valley:
          case ObstacleKind.lake:
          case ObstacleKind.lava:
          case ObstacleKind.volcanicLake:
            break; // already painted as a continuous ribbon/pond above
          case null:
            break; // open ground - trees are drawn live, see [paintTrees]
        }
      }
    }
  }

  /// Live per-frame animated overlay for a lava ribbon: a pulsing bright
  /// glow (brightness oscillates with [phase]) plus drifting ember specks,
  /// on top of the static [_paintLavaBed].
  static void paintLavaFlow(
    ui.Canvas canvas,
    ui.Path path,
    double cellSize,
    double phase,
  ) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final pulse = 0.5 + 0.5 * sin(phase * 2.2);
    final glowPaint = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..strokeWidth = cellSize * (0.5 + pulse * 0.15)
      ..color = ui.Color.lerp(
        const ui.Color(0xFFff7a1a),
        const ui.Color(0xFFffe066),
        pulse,
      )!.withValues(alpha: 0.35 + pulse * 0.25)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);

    final emberPaint = ui.Paint()..color = const ui.Color(0xFFffcf7a);
    final rnd = Random(11);
    for (final metric in metrics) {
      final length = metric.length;
      if (length <= 0) continue;
      final emberCount = (length / (cellSize * 1.2)).floor().clamp(0, 200);
      for (var i = 0; i < emberCount; i++) {
        final baseDist = (i + 0.5) * (length / emberCount);
        // Embers drift upward off the flow instead of along it.
        final rise = ((phase * 30 + i * 37) % 60);
        final dist = (baseDist + rnd.nextDouble() * cellSize * 0.4) % length;
        final tangent = metric.getTangentForOffset(dist);
        if (tangent == null) continue;
        final jitter = (rnd.nextDouble() - 0.5) * cellSize * 0.6;
        final normal = ui.Offset(-tangent.vector.dy, tangent.vector.dx);
        final center =
            tangent.position + normal * jitter - ui.Offset(0, rise * 0.3);
        final alpha = (1 - rise / 60).clamp(0.0, 1.0);
        canvas.drawCircle(
          center,
          1.4,
          emberPaint..color = emberPaint.color.withValues(alpha: alpha * 0.8),
        );
      }
    }
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
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

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
    final ripplePaint = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const ui.Color(0xFFe8fbff).withValues(alpha: 0.3);

    for (final metric in metrics) {
      final length = metric.length;
      if (length <= 0) continue;

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
      if (rippleCount == 0) continue;
      final rnd = Random(7);
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
  }

  /// Live per-frame companion to [paint] (which never draws trees itself)
  /// - redrawn every frame so each canopy's [_treeSway] offset can respond
  /// to [windStrength] as [phase] (elapsed seconds) advances, instead of
  /// standing perfectly still. Only draws [TerrainMap.treeCells] - a
  /// biome never automatically sprouts trees the map's own data doesn't
  /// have; procedurally generated scenes bake their forest cover into
  /// [TerrainMap.treeCells] once at generation time (see
  /// `TerrainRepositoryImpl._scatterTrees`), and map-editor-authored maps
  /// rely solely on their own Tree brush placements.
  static void paintTrees(
    ui.Canvas canvas,
    ui.Size size,
    TerrainMap terrainMap, {
    double windStrength = 0,
    double phase = 0,
  }) {
    if (terrainMap.treeCells.isEmpty) return;
    final grid = terrainMap.grid;
    final kinds = terrainMap.obstacleKinds;

    // Fresh, dedicated seed every call so scatter jitter/scale stay fixed
    // across frames; only the sway offset (driven by [phase], not this
    // RNG) actually animates.
    final rnd = Random(1337);
    for (final tree in terrainMap.treeCells) {
      if (tree.y < 0 || tree.y >= grid.rows) continue;
      if (tree.x < 0 || tree.x >= grid.cols) continue;
      if (kinds[tree.y][tree.x] != null) continue;
      _paintTree(
        canvas,
        grid,
        tree.x,
        tree.y,
        rnd,
        terrainMap.biomeAt(tree.x, tree.y),
        sway: _treeSway(tree.x, tree.y, windStrength, phase),
      );
    }
  }

  /// Combined path of every river segment in [terrainMap] (one subpath per
  /// connected group of river cells), smoothed - null if this map has no
  /// river (e.g. desert biome, which uses a dry valley instead). Used both
  /// to bake the static bed (see [_paintRiverBed]) and to drive the live
  /// [paintRiverFlow] overlay. Pass `kind: ObstacleKind.lava` to get the
  /// equivalent path for lava ribbons instead.
  static ui.Path? riverPath(
    TerrainMap terrainMap,
    double canvasHeight, {
    ObstacleKind kind = ObstacleKind.river,
  }) {
    final chains = _obstacleChains(
      terrainMap.grid,
      terrainMap.obstacleKinds,
      kind,
      canvasHeight,
    );
    final combined = ui.Path();
    var hasAny = false;
    for (final chain in chains) {
      if (chain.length < 2) continue;
      combined.addPath(_smoothPath(chain), ui.Offset.zero);
      hasAny = true;
    }
    return hasAny ? combined : null;
  }

  /// Resolves the brush-type [Biome] painted at a chain's first point, for
  /// tinting that river ribbon - falls back to the map's own biome when the
  /// point falls outside the grid (e.g. an edge-extended chain endpoint).
  static Biome _chainBiome(
    TerrainMap terrainMap,
    Grid grid,
    List<ui.Offset> chain,
  ) {
    final first = chain.first;
    final col = (first.dx / grid.cellSize).floor().clamp(0, grid.cols - 1);
    final row = (first.dy / grid.cellSize).floor().clamp(0, grid.rows - 1);
    return terrainMap.biomeAt(col, row);
  }

  /// Orders a connected group of cells into a single spatially-coherent
  /// chain: starts from the lowest-degree cell (a true endpoint for a
  /// snake-shaped stroke, or an arbitrary cell for a closed loop/blob),
  /// then greedily walks to the nearest not-yet-visited cell.
  static List<Point<int>> _chainCells(List<Point<int>> cells) {
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

  /// Flood-fills [kinds] (8-directional) into groups of adjacent cells that
  /// all match [kind].
  static List<List<Point<int>>> _connectedCells(
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

  /// One ordered point-chain per connected group of [kind] cells, so any
  /// hand-drawn shape (not just a single top-to-bottom crossing) renders as
  /// its actual path rather than collapsing to one line - ordering is
  /// reconstructed from real cell adjacency since [TerrainMap] only stores
  /// the rasterized grid, not the original drawn stroke. A chain that
  /// touches the top/bottom grid edge is extended straight to the matching
  /// canvas edge so it doesn't visibly stop short of the border.
  static List<List<ui.Offset>> _obstacleChains(
    Grid grid,
    List<List<ObstacleKind?>> kinds,
    ObstacleKind kind,
    double canvasHeight,
  ) {
    final chains = <List<ui.Offset>>[];
    for (final component in _connectedCells(grid, kinds, kind)) {
      final ordered = _chainCells(component);
      if (ordered.isEmpty) continue;
      final points = ordered
          .map(
            (c) => ui.Offset(
              c.x * grid.cellSize + grid.cellSize / 2,
              c.y * grid.cellSize + grid.cellSize / 2,
            ),
          )
          .toList();
      if (ordered.first.y == 0) {
        points.insert(0, ui.Offset(points.first.dx, 0));
      }
      if (ordered.last.y == grid.rows - 1) {
        points.add(ui.Offset(points.last.dx, canvasHeight));
      }
      chains.add(points);
    }
    return chains;
  }

  /// A flattened, wide-spread canopy on a taller trunk - reads as an acacia
  /// silhouette against open savanna grassland.
  static void _paintAcaciaCanopy(
    ui.Canvas canvas,
    double cx,
    double cy,
    double scale,
  ) {
    _paintTrunk(canvas, cx, cy, scale, height: 12, color: 0xFF5a3f1f);
    canvas.drawOval(
      ui.Rect.fromCenter(
        center: ui.Offset(cx, cy - 11 * scale),
        width: 26 * scale,
        height: 9 * scale,
      ),
      ui.Paint()..color = const ui.Color(0xFF6b7a3d).withValues(alpha: 0.92),
    );
    canvas.drawOval(
      ui.Rect.fromCenter(
        center: ui.Offset(cx - 4 * scale, cy - 13 * scale),
        width: 12 * scale,
        height: 5 * scale,
      ),
      ui.Paint()..color = const ui.Color(0xFF8a9a4a).withValues(alpha: 0.6),
    );
  }

  /// Layered conical tiers (blue-white, snow-capped) for the icy peaks -
  /// distinct from the tundra's frosted broadleaf look.
  static void _paintConiferCanopy(
    ui.Canvas canvas,
    double cx,
    double cy,
    double scale,
  ) {
    _paintTrunk(canvas, cx, cy, scale, height: 8, color: 0xFF3a3228);
    const tiers = [0.0, -5.0, -9.5];
    for (final dy in tiers) {
      final width = (16 - tiers.indexOf(dy) * 3) * scale;
      final tierCenter = ui.Offset(cx, cy + dy * scale - 3 * scale);
      final path = ui.Path()
        ..moveTo(tierCenter.dx - width / 2, tierCenter.dy + 4 * scale)
        ..lineTo(tierCenter.dx, tierCenter.dy - 5 * scale)
        ..lineTo(tierCenter.dx + width / 2, tierCenter.dy + 4 * scale)
        ..close();
      canvas.drawPath(
        path,
        ui.Paint()..color = const ui.Color(0xFF375a52).withValues(alpha: 0.9),
      );
    }
    canvas.drawCircle(
      ui.Offset(cx, cy - 12.5 * scale),
      3.2 * scale,
      ui.Paint()..color = const ui.Color(0xFFFFFFFF).withValues(alpha: 0.85),
    );
  }

  /// A couple of leafless, forked branches - no canopy - for the arid dunes.
  static void _paintDesertTree(
    ui.Canvas canvas,
    double cx,
    double cy,
    double scale,
  ) {
    final paint = ui.Paint()
      ..color = const ui.Color(0xFF7a5c3d)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.2 * scale
      ..strokeCap = ui.StrokeCap.round;
    final base = ui.Offset(cx, cy + 8 * scale);
    final mid = ui.Offset(cx, cy - 2 * scale);
    canvas.drawLine(base, mid, paint);
    for (final branch in [
      ui.Offset(cx - 9 * scale, cy - 9 * scale),
      ui.Offset(cx + 8 * scale, cy - 8 * scale),
      ui.Offset(cx - 3 * scale, cy - 12 * scale),
    ]) {
      canvas.drawLine(mid, branch, paint);
    }
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

  /// Dense, darker overlapping foliage blobs - a thicker rainforest canopy
  /// than the default grassland tree.
  static void _paintForestCanopy(
    ui.Canvas canvas,
    double cx,
    double cy,
    double scale,
  ) {
    _paintTrunk(canvas, cx, cy, scale);
    const lobes = [
      (dx: 0.0, dy: -3.0, scale: 1.15),
      (dx: -7.0, dy: 1.5, scale: 0.9),
      (dx: 7.0, dy: 1.5, scale: 0.95),
      (dx: -3.0, dy: 5.0, scale: 0.85),
      (dx: 4.0, dy: 5.5, scale: 0.8),
    ];
    for (final lobe in lobes) {
      canvas.drawCircle(
        ui.Offset(cx + lobe.dx * scale, cy + lobe.dy * scale - 4 * scale),
        9 * scale * lobe.scale,
        ui.Paint()..color = const ui.Color(0xFF14311a).withValues(alpha: 0.94),
      );
    }
    canvas.drawCircle(
      ui.Offset(cx - 5 * scale, cy - 9 * scale),
      6 * scale,
      ui.Paint()..color = const ui.Color(0xFF3a7a3f).withValues(alpha: 0.55),
    );
  }

  /// Fills a connected blob of lake cells as one unioned pond shape (an
  /// area feature, unlike the linear river/valley ribbons).
  static void _paintLake(
    ui.Canvas canvas,
    List<Point<int>> cells,
    double cellSize,
    BiomePalette palette,
  ) {
    if (cells.isEmpty) return;
    var shape = ui.Path();
    for (final cell in cells) {
      final rect = ui.Rect.fromLTWH(
        cell.x * cellSize - 2,
        cell.y * cellSize - 2,
        cellSize + 4,
        cellSize + 4,
      );
      final piece = ui.Path()
        ..addRRect(
          ui.RRect.fromRectAndRadius(rect, ui.Radius.circular(cellSize * 0.4)),
        );
      shape = ui.Path.combine(ui.PathOperation.union, shape, piece);
    }
    final bounds = shape.getBounds();
    canvas.drawPath(
      shape,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.5
        ..color = ui.Color.lerp(
          const ui.Color(0xFFd8c48a),
          palette.groundMid,
          0.4,
        )!.withValues(alpha: 0.45),
    );
    canvas.drawPath(
      shape,
      ui.Paint()
        ..shader = ui.Gradient.linear(
          bounds.topCenter,
          bounds.bottomCenter,
          [
            for (final c in const [
              ui.Color(0xFF0a3450),
              ui.Color(0xFF1f7fa8),
              ui.Color(0xFF0a3450),
            ])
              ui.Color.lerp(c, palette.capColor, 0.22)!,
          ],
          const [0.0, 0.5, 1.0],
        ),
    );
  }

  /// Molten counterpart of [_paintRiverBed] - a charcoal/basalt bank
  /// around a glowing magma channel. Deliberately not [BiomePalette]-
  /// tinted: lava looks the same regardless of biome.
  static void _paintLavaBed(ui.Canvas canvas, ui.Path path, double cellSize) {
    final bounds = path.getBounds();
    // Cooled charcoal/basalt bank, wider than the molten channel itself.
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..strokeWidth = cellSize * 2.0
        ..color = const ui.Color(0xFF241a17).withValues(alpha: 0.6),
    );
    // Scorched, darker rock right at the flow's edge.
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..strokeWidth = cellSize * 1.5
        ..color = const ui.Color(0xFF120b09).withValues(alpha: 0.7),
    );
    // Molten channel with a deep-to-bright gradient across its width.
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
          [
            const ui.Color(0xFF3a0d02),
            const ui.Color(0xFFd93a0a),
            const ui.Color(0xFF3a0d02),
            const ui.Color(0xFFd93a0a),
            const ui.Color(0xFF3a0d02),
          ],
          const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
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

  /// A curved trunk plus radiating frond blades - reads as a palm on the
  /// sea biome's coastal reefs/islets.
  static void _paintPalmCanopy(
    ui.Canvas canvas,
    double cx,
    double cy,
    double scale,
  ) {
    final trunkPath = ui.Path()
      ..moveTo(cx - 2 * scale, cy + 9 * scale)
      ..quadraticBezierTo(
        cx + 5 * scale,
        cy + 2 * scale,
        cx + 1 * scale,
        cy - 9 * scale,
      );
    canvas.drawPath(
      trunkPath,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3 * scale
        ..color = const ui.Color(0xFF8a6a3f),
    );
    final crown = ui.Offset(cx + 1 * scale, cy - 9 * scale);
    for (final angle in [-1.1, -0.5, 0.0, 0.5, 1.1]) {
      final tip = ui.Offset(
        crown.dx + cos(angle) * 13 * scale,
        crown.dy + sin(angle) * 8 * scale - 3 * scale,
      );
      canvas.drawLine(
        crown,
        tip,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 2.4 * scale
          ..strokeCap = ui.StrokeCap.round
          ..color = const ui.Color(0xFF2f7a4a),
      );
    }
  }

  /// Static shore/bed/water-gradient layers only - baked once into the
  /// cached terrain image. The moving shimmer/ripples are drawn separately
  /// every frame by [paintRiverFlow] so the river reads as flowing water.
  static void _paintRiverBed(
    ui.Canvas canvas,
    ui.Path path,
    double cellSize,
    BiomePalette palette,
  ) {
    final bounds = path.getBounds();
    // Sandy shore first, wider than the water itself - tinted by the
    // river's brush type (e.g. a frozen-variant river gets a pale, icy
    // shore instead of the default warm sand).
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..strokeWidth = cellSize * 2.0
        ..color = ui.Color.lerp(
          const ui.Color(0xFFd8c48a),
          palette.groundMid,
          0.4,
        )!.withValues(alpha: 0.55),
    );
    // Wet, darker sand right at the waterline.
    canvas.drawPath(
      path,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..strokeWidth = cellSize * 1.5
        ..color = ui.Color.lerp(
          const ui.Color(0xFF9c8256),
          palette.groundBottom,
          0.4,
        )!.withValues(alpha: 0.6),
    );
    // Water body with a deep-to-mid gradient across its width, tinted
    // toward the brush type's cap color (icy pale for snow/frozen, murky
    // for desert, etc.).
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
          [
            for (final c in const [
              ui.Color(0xFF0a3450),
              ui.Color(0xFF1f7fa8),
              ui.Color(0xFF0a3450),
              ui.Color(0xFF1f7fa8),
              ui.Color(0xFF0a3450),
            ])
              ui.Color.lerp(c, palette.capColor, 0.22)!,
          ],
          const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
    );
  }

  /// The default grassland canopy: rounded, overlapping foliage blobs
  /// instead of flat pine tiers - a cluster of clumps reads as a top-down
  /// tree canopy, RA2-style.
  static void _paintRoundCanopy(
    ui.Canvas canvas,
    double cx,
    double cy,
    double scale,
  ) {
    _paintTrunk(canvas, cx, cy, scale);
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

  /// A handful of bare, blackened branches - a scorched tree among the
  /// ruins, no living canopy left.
  static void _paintScorchedTree(
    ui.Canvas canvas,
    double cx,
    double cy,
    double scale,
  ) {
    final paint = ui.Paint()
      ..color = const ui.Color(0xFF2a2622)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.4 * scale
      ..strokeCap = ui.StrokeCap.round;
    final base = ui.Offset(cx, cy + 8 * scale);
    final mid = ui.Offset(cx - 1 * scale, cy - 3 * scale);
    canvas.drawLine(base, mid, paint);
    for (final branch in [
      ui.Offset(cx - 10 * scale, cy - 7 * scale),
      ui.Offset(cx + 7 * scale, cy - 10 * scale),
      ui.Offset(cx + 2 * scale, cy - 13 * scale),
    ]) {
      canvas.drawLine(mid, branch, paint);
    }
    canvas.drawCircle(
      mid,
      2 * scale,
      ui.Paint()..color = const ui.Color(0xFF5c3f2e).withValues(alpha: 0.4),
    );
  }

  /// Same rounded canopy as the default tree, but frosted with a snow cap
  /// on top - the tundra's trees stay green under a dusting of snow rather
  /// than turning into conifers.
  static void _paintSnowyCanopy(
    ui.Canvas canvas,
    double cx,
    double cy,
    double scale,
  ) {
    _paintRoundCanopy(canvas, cx, cy, scale);
    canvas.drawArc(
      ui.Rect.fromCenter(
        center: ui.Offset(cx, cy - 8 * scale),
        width: 20 * scale,
        height: 16 * scale,
      ),
      pi,
      pi,
      false,
      ui.Paint()..color = const ui.Color(0xFFFFFFFF).withValues(alpha: 0.75),
    );
  }

  /// Trees adapt their silhouette/color to the biome they're planted on
  /// (whether scattered automatically or hand-placed via the map editor's
  /// Tree brush) instead of always looking like the same grassland tree -
  /// a snow-capped conifer on the tundra reads very differently from a
  /// scorched dead tree in the ruins.
  static void _paintTree(
    ui.Canvas canvas,
    Grid grid,
    int col,
    int row,
    Random rnd,
    Biome biome, {
    double sway = 0,
  }) {
    final cx =
        col * grid.cellSize + grid.cellSize / 2 + (rnd.nextDouble() - 0.5) * 8;
    final cy =
        row * grid.cellSize + grid.cellSize / 2 + (rnd.nextDouble() - 0.5) * 8;
    final scale = 0.7 + rnd.nextDouble() * 0.5;
    // Only the canopy leans with [sway] - the shadow stays put so the
    // trunk still reads as planted in the ground while it tips.
    final canopyCx = cx + sway;

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

    switch (biome) {
      case Biome.mountainForest:
        _paintForestCanopy(canvas, canopyCx, cy, scale);
      case Biome.savanna:
        _paintAcaciaCanopy(canvas, canopyCx, cy, scale);
      case Biome.snowTundra:
        _paintSnowyCanopy(canvas, canopyCx, cy, scale);
      case Biome.frozenPeaks:
        _paintConiferCanopy(canvas, canopyCx, cy, scale);
      case Biome.desertDunes:
        _paintDesertTree(canvas, canopyCx, cy, scale);
      case Biome.sea:
        _paintPalmCanopy(canvas, canopyCx, cy, scale);
      case Biome.cityRuins:
        _paintScorchedTree(canvas, canopyCx, cy, scale);
      case Biome.grassPlains:
        _paintRoundCanopy(canvas, canopyCx, cy, scale);
    }
  }

  /// Shared trunk shape used by every canopy style except the desert/ruins
  /// dead branches and the sea biome's curved palm trunk.
  static void _paintTrunk(
    ui.Canvas canvas,
    double cx,
    double cy,
    double scale, {
    double height = 8,
    int color = 0xFF4a3421,
  }) {
    canvas.drawRect(
      ui.Rect.fromCenter(
        center: ui.Offset(cx, cy + (height / 2) * scale),
        width: 3 * scale,
        height: height * scale,
      ),
      ui.Paint()..color = ui.Color(color),
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

    final rnd = Random(11);
    for (final metric in path.computeMetrics()) {
      final rockCount = (metric.length / (cellSize * 1.1)).floor();
      if (rockCount == 0) continue;
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

  /// Molten counterpart of [_paintLake] - a charcoal shore ring around a
  /// glowing magma fill. Deliberately not [BiomePalette]-tinted (unlike
  /// [_paintLake]/[_paintRiverBed]): lava looks the same regardless of
  /// biome.
  static void _paintVolcanicLake(
    ui.Canvas canvas,
    List<Point<int>> cells,
    double cellSize,
  ) {
    if (cells.isEmpty) return;
    var shape = ui.Path();
    for (final cell in cells) {
      final rect = ui.Rect.fromLTWH(
        cell.x * cellSize - 2,
        cell.y * cellSize - 2,
        cellSize + 4,
        cellSize + 4,
      );
      final piece = ui.Path()
        ..addRRect(
          ui.RRect.fromRectAndRadius(rect, ui.Radius.circular(cellSize * 0.4)),
        );
      shape = ui.Path.combine(ui.PathOperation.union, shape, piece);
    }
    final bounds = shape.getBounds();
    canvas.drawPath(
      shape,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.5
        ..color = const ui.Color(0xFF261a16).withValues(alpha: 0.6),
    );
    canvas.drawPath(
      shape,
      ui.Paint()
        ..shader = ui.Gradient.linear(
          bounds.topCenter,
          bounds.bottomCenter,
          [
            const ui.Color(0xFF3a0d02),
            const ui.Color(0xFFd93a0a),
            const ui.Color(0xFFffb347),
            const ui.Color(0xFFd93a0a),
            const ui.Color(0xFF3a0d02),
          ],
          const [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
    );
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

  /// A small sideways offset for one tree's canopy, driven by a sine wave
  /// over elapsed [phase] seconds and scaled by [windStrength] (0..1). The
  /// phase offset is derived from the tree's own cell (not [Random], which
  /// is reserved for placement/jitter) so it stays fixed across frames and
  /// makes a whole forest sway out of sync instead of snapping side to
  /// side in lockstep.
  static double _treeSway(int col, int row, double windStrength, double phase) {
    if (windStrength <= 0) return 0;
    final offset = ((col * 13 + row * 31) % 100) / 100.0 * 2 * pi;
    return sin(phase * 1.6 + offset) * windStrength.clamp(0, 1) * 6.0;
  }
}
