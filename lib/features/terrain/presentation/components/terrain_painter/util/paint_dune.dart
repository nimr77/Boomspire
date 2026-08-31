import 'dart:ui' as ui;

import '../../../../../../core/pathfinding/grid.dart';
import '../../../../domain/models/biome.dart';

/// Bakes one dune cell's wind-swept ridge silhouette and gradient fill.
void paintDune(
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
    ..quadraticBezierTo(cx - half * 0.2, cy - half * 0.85, cx, cy - half * 0.55)
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
