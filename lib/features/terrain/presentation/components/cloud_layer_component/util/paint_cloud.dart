import 'dart:math';
import 'dart:ui' as ui;

import 'cloud_drift_metrics.dart';

/// Paints one cloud as a cluster of blurred circles - a stable,
/// per-frame-reproducible puff layout driven by [seed] (each frame
/// recreates the same [Random] sequence so the shape doesn't flicker),
/// drifting/breathing over time via [bobPhase]. [depth] scales both size
/// and blur softness for a cheap parallax cue.
void paintCloud(
  ui.Canvas canvas, {
  required int seed,
  required double positionX,
  required double positionY,
  required double bobPhase,
  required double scale,
  required double baseOpacity,
  required double depth,
}) {
  final rnd = Random(seed);
  final cloudDrift = cloudDriftMetrics(bobPhase);
  final base = ui.Offset(positionX, positionY + cloudDrift.drift);
  final breathe = cloudDrift.breathe;
  final paint = ui.Paint()
    ..color = const ui.Color(0xFFFFFFFF)
        .withValues(alpha: baseOpacity * breathe)
    ..maskFilter = ui.MaskFilter.blur(
      ui.BlurStyle.normal,
      14 + (1 - depth) * 10,
    );
  for (var puff = 0; puff < 5; puff++) {
    final dx = (rnd.nextDouble() - 0.5) * 90 * scale;
    final dy = (rnd.nextDouble() - 0.5) * 24 * scale;
    final r = (26 + rnd.nextDouble() * 22) * scale * depth;
    canvas.drawCircle(base.translate(dx, dy), r, paint);
  }
}
