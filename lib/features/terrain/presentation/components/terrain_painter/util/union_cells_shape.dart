import 'dart:math';
import 'dart:ui' as ui;

/// Fills a connected blob of cells as one unioned shape (an area feature,
/// unlike the linear river/valley ribbons). Unions every cell's rounded
/// rect into one blob shape - shared by `TerrainPainter._paintLake`/
/// `_paintVolcanicLake` (baked once) and `TerrainPainter.lakeShape` (the
/// combined shape passed to the live `paintLakeFlow`/
/// `paintVolcanicLakeFlow` overlays).
ui.Path unionCellsShape(List<Point<int>> cells, double cellSize) {
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
  return shape;
}
