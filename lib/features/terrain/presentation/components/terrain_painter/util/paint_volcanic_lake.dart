import 'dart:math';
import 'dart:ui' as ui;

import 'union_cells_shape.dart';

/// Molten counterpart of `paintLake` - a charcoal shore ring around a
/// glowing magma fill. Deliberately not `BiomePalette`-tinted (unlike
/// `paintLake`/`paintRiverBed`): lava looks the same regardless of biome.
void paintVolcanicLake(
  ui.Canvas canvas,
  List<Point<int>> cells,
  double cellSize,
) {
  if (cells.isEmpty) return;
  final shape = unionCellsShape(cells, cellSize);
  final bounds = shape.getBounds();
  canvas.drawPath(
    shape,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.7
      ..color = const ui.Color(0xFF241a17).withValues(alpha: 0.5)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5),
  );
  canvas.drawPath(
    shape,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.4
      ..color = const ui.Color(0xFF261a16).withValues(alpha: 0.7),
  );

  canvas.save();
  canvas.clipPath(shape);
  // Radial (hot core, cooler toward the shore) fill instead of a flat
  // top-to-bottom stripe.
  canvas.drawRect(
    bounds,
    ui.Paint()
      ..shader = ui.Gradient.radial(
        bounds.center,
        max(bounds.width, bounds.height) * 0.65,
        const [
          ui.Color(0xFFffcf6b),
          ui.Color(0xFFd93a0a),
          ui.Color(0xFF3a0d02),
        ],
        const [0.0, 0.5, 1.0],
      ),
  );
  // Organic convection-cell blobs so the molten body reads as a churning
  // liquid instead of a flat gradient fill.
  final rnd = Random(cells.first.x * 577 + cells.first.y * 349 + 1);
  for (var i = 0; i < (cells.length * 3).clamp(6, 60); i++) {
    final x = bounds.left + rnd.nextDouble() * bounds.width;
    final y = bounds.top + rnd.nextDouble() * bounds.height;
    canvas.drawCircle(
      ui.Offset(x, y),
      cellSize * (0.18 + rnd.nextDouble() * 0.26),
      ui.Paint()
        ..color =
            (rnd.nextBool()
                    ? const ui.Color(0xFFffe066)
                    : const ui.Color(0xFF3a0d02))
                .withValues(alpha: 0.16)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 7),
    );
  }
  canvas.restore();
}
