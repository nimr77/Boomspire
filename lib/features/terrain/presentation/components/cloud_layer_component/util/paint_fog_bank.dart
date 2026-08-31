import 'dart:math';
import 'dart:ui' as ui;

import 'fog_drift_metrics.dart';

/// Paints one ground-fog bank as a cluster of blurred ovals - a stable,
/// per-frame-reproducible puff layout driven by [seed] (each frame
/// recreates the same [Random] sequence so the shape doesn't flicker),
/// drifting/breathing over time via [bobPhase].
void paintFogBank(
  ui.Canvas canvas, {
  required int seed,
  required double positionX,
  required double positionY,
  required double bobPhase,
  required double scale,
  required double baseOpacity,
}) {
  final rnd = Random(seed);
  final fogDrift = fogDriftMetrics(bobPhase);
  final base = ui.Offset(positionX, positionY + fogDrift.drift);
  final breathe = fogDrift.breathe;
  final paint = ui.Paint()
    ..color = const ui.Color(0xFFDCE6EE)
        .withValues(alpha: baseOpacity * breathe)
    ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 30);
  for (var puff = 0; puff < 4; puff++) {
    final dx = (rnd.nextDouble() - 0.5) * 220 * scale;
    final dy = (rnd.nextDouble() - 0.5) * 18 * scale;
    final r = (60 + rnd.nextDouble() * 50) * scale;
    canvas.drawOval(
      ui.Rect.fromCenter(
        center: base.translate(dx, dy),
        width: r * 2.4,
        height: r * 0.7,
      ),
      paint,
    );
  }
}
