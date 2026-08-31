import 'dart:math';
import 'dart:ui' as ui;

import '../../../../domain/models/biome.dart';
import 'union_cells_shape.dart';

/// A natural, glassy-looking still pond: a radial (sunlit center, deeper
/// toward the shore) gradient instead of a flat top-to-bottom stripe, soft
/// organic current mottling, and a static sheen highlight - the live
/// shimmer/ripples are drawn separately every frame by
/// `TerrainPainter.paintLakeFlow`.
void paintLake(
  ui.Canvas canvas,
  List<Point<int>> cells,
  double cellSize,
  BiomePalette palette,
) {
  if (cells.isEmpty) return;
  final shape = unionCellsShape(cells, cellSize);
  final bounds = shape.getBounds();
  final shoreColor = ui.Color.lerp(
    const ui.Color(0xFFd8c48a),
    palette.groundMid,
    0.4,
  )!;
  // Soft, wide shore blur so the bank melts into the surrounding ground
  // instead of reading as a sharp cutout.
  canvas.drawPath(
    shape,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.7
      ..color = shoreColor.withValues(alpha: 0.35)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5),
  );
  canvas.drawPath(
    shape,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.42
      ..color = shoreColor.withValues(alpha: 0.5),
  );

  final deep = ui.Color.lerp(
    const ui.Color(0xFF07283f),
    palette.capColor,
    0.15,
  )!;
  final mid = ui.Color.lerp(
    const ui.Color(0xFF1c8a9e),
    palette.capColor,
    0.25,
  )!;
  final surface = ui.Color.lerp(
    const ui.Color(0xFF6fd0dd),
    palette.capColor,
    0.3,
  )!;
  canvas.save();
  canvas.clipPath(shape);
  // Natural pond depth: a lighter, sunlit center fading out toward a
  // darker edge instead of a flat top-to-bottom stripe.
  canvas.drawRect(
    bounds,
    ui.Paint()
      ..shader = ui.Gradient.radial(
        bounds.center,
        max(bounds.width, bounds.height) * 0.65,
        [surface, mid, deep],
        const [0.0, 0.55, 1.0],
      ),
  );
  // Subtle organic current mottling so the body isn't a flat fill.
  final rnd = Random(cells.first.x * 733 + cells.first.y * 911);
  for (var i = 0; i < (cells.length * 3).clamp(6, 60); i++) {
    final x = bounds.left + rnd.nextDouble() * bounds.width;
    final y = bounds.top + rnd.nextDouble() * bounds.height;
    canvas.drawCircle(
      ui.Offset(x, y),
      cellSize * (0.18 + rnd.nextDouble() * 0.22),
      ui.Paint()
        ..color = (rnd.nextBool() ? surface : deep).withValues(alpha: 0.08)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
    );
  }
  // Static glassy sheen - a soft bright streak near one edge, like a
  // permanent light reflection on the surface.
  canvas.drawOval(
    ui.Rect.fromCenter(
      center: ui.Offset(
        bounds.left + bounds.width * 0.32,
        bounds.top + bounds.height * 0.28,
      ),
      width: bounds.width * 0.5,
      height: bounds.height * 0.16,
    ),
    ui.Paint()
      ..color = const ui.Color(0xFFEAFBFF).withValues(alpha: 0.18)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8),
  );
  canvas.restore();
}
