import 'dart:math';
import 'dart:ui' as ui;

/// Bakes one valley/canyon cell chain's sunlit rim, gradient floor, erosion
/// crack detail and scattered rock dabs.
void paintValleyPath(ui.Canvas canvas, ui.Path path, double cellSize) {
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
