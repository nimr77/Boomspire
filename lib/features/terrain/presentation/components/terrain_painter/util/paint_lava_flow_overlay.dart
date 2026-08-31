import 'dart:math';
import 'dart:ui' as ui;

import 'lava_flow_ember_dist.dart';
import 'lava_flow_ember_rise.dart';
import 'lava_flow_glow_math.dart';

/// Live per-frame animated overlay for a lava ribbon: a pulsing bright
/// glow (brightness oscillates with [phase]) plus drifting ember specks,
/// on top of the static `paintLavaBed`.
void paintLavaFlowOverlay(
  ui.Canvas canvas,
  ui.Path path,
  double cellSize,
  double phase,
) {
  final metrics = path.computeMetrics().toList();
  if (metrics.isEmpty) return;

  final glow = lavaFlowGlowMetrics(phase: phase, cellSize: cellSize);
  final glowPaint = ui.Paint()
    ..style = ui.PaintingStyle.stroke
    ..strokeCap = ui.StrokeCap.round
    ..strokeJoin = ui.StrokeJoin.round
    ..strokeWidth = glow.strokeWidth
    ..color = ui.Color.lerp(
      const ui.Color(0xFFff7a1a),
      const ui.Color(0xFFffe066),
      glow.pulse,
    )!.withValues(alpha: glow.alpha)
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
      final riseMetrics = lavaFlowEmberRise(index: i, phase: phase);
      final dist = lavaFlowEmberDist(
        baseDist: baseDist,
        randJitter: rnd.nextDouble(),
        cellSize: cellSize,
        length: length,
      );
      final tangent = metric.getTangentForOffset(dist);
      if (tangent == null) continue;
      final jitter = (rnd.nextDouble() - 0.5) * cellSize * 0.6;
      final normal = ui.Offset(-tangent.vector.dy, tangent.vector.dx);
      final center =
          tangent.position +
          normal * jitter -
          ui.Offset(0, riseMetrics.rise * 0.3);
      // Fade in then out, so a fresh ember never pops in at full
      // brightness and never vanishes abruptly either.
      canvas.drawCircle(
        center,
        1.4,
        emberPaint
          ..color = emberPaint.color.withValues(alpha: riseMetrics.alpha * 0.8),
      );
    }
  }
}
