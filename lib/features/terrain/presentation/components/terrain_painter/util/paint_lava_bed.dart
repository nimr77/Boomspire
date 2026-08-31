import 'dart:math';
import 'dart:ui' as ui;

/// Molten counterpart of `paintRiverBed` - a charcoal/basalt bank around a
/// glowing magma channel. Deliberately not `BiomePalette`-tinted: lava
/// looks the same regardless of biome.
void paintLavaBed(ui.Canvas canvas, ui.Path path, double cellSize) {
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
  // Organic magma blobs along the channel so the molten body reads as a
  // churning liquid instead of a flat gradient stripe.
  final rnd = Random(53);
  for (final metric in path.computeMetrics()) {
    final length = metric.length;
    if (length <= 0) continue;
    final blobCount = (length / (cellSize * 0.9)).floor().clamp(0, 200);
    if (blobCount == 0) continue;
    for (var i = 0; i < blobCount; i++) {
      final dist = ((i + rnd.nextDouble() * 0.6) * (length / blobCount)).clamp(
        0.0,
        length,
      );
      final tangent = metric.getTangentForOffset(dist);
      if (tangent == null) continue;
      final normal = ui.Offset(-tangent.vector.dy, tangent.vector.dx);
      final jitter = (rnd.nextDouble() - 0.5) * cellSize * 0.5;
      final center = tangent.position + normal * jitter;
      canvas.drawCircle(
        center,
        cellSize * (0.14 + rnd.nextDouble() * 0.18),
        ui.Paint()
          ..color =
              (rnd.nextBool()
                      ? const ui.Color(0xFFffcf6b)
                      : const ui.Color(0xFF2a0a01))
                  .withValues(alpha: 0.16)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4),
      );
    }
  }
}
