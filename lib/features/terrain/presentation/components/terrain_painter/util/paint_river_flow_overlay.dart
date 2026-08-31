import 'dart:math';
import 'dart:ui' as ui;

import 'river_flow_band_math.dart';
import 'river_flow_glint_math.dart';
import 'river_flow_ripple_math.dart';

/// Live per-frame animated overlay for a river: soft, blurred glassy
/// highlight bands ripple along the flow (a translucent, softly-lit
/// glassy "wave" look, rather than crisp dashes) plus gentle shimmering
/// glints and expanding ripple rings - all drift downstream as [phase]
/// (elapsed seconds) advances, on top of the static `paintRiverBed`.
void paintRiverFlowOverlay(
  ui.Canvas canvas,
  ui.Path path,
  double cellSize,
  double phase,
) {
  final metrics = path.computeMetrics().toList();
  if (metrics.isEmpty) return;

  const bandLen = 46.0;
  const gapLen = 34.0;
  const period = bandLen + gapLen;
  final flowOffset = (phase * 62) % period;
  final glassPaint = ui.Paint()
    ..style = ui.PaintingStyle.stroke
    ..strokeCap = ui.StrokeCap.round
    ..strokeJoin = ui.StrokeJoin.round
    ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3.4);
  final glintPaint = ui.Paint()
    ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.2);
  final ripplePaint = ui.Paint()
    ..style = ui.PaintingStyle.stroke
    ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.5);

  for (final metric in metrics) {
    final length = metric.length;
    if (length <= 0) continue;

    // Soft glassy bands: wide, blurred, gently wobbling highlight strokes
    // that read as light refracting through moving water rather than a
    // hard specular line.
    for (var dist = -flowOffset; dist < length; dist += period) {
      final start = dist.clamp(0.0, length);
      final end = (dist + bandLen).clamp(0.0, length);
      if (end <= start) continue;
      final sub = metric.extractPath(start, end);
      // Fade the band as it's clipped entering/leaving the visible
      // range, instead of popping in/out at full strength.
      final band = riverFlowBandMetrics(
        phase: phase,
        dist: dist,
        cellSize: cellSize,
        start: start,
        end: end,
        bandLen: bandLen,
      );
      glassPaint
        ..strokeWidth = band.strokeWidth
        ..color = const ui.Color(0xFFdcfbff)
            .withValues(alpha: 0.16 * band.visibleFraction);
      canvas.drawPath(sub.shift(ui.Offset(-3, band.wobble - 3)), glassPaint);
    }

    // Small shimmering glints, pulsing gently as they drift downstream.
    final glintCount = (length / (cellSize * 1.6)).floor().clamp(0, 160);
    if (glintCount > 0) {
      final rnd = Random(7);
      final step = length / glintCount;
      for (var i = 0; i < glintCount; i++) {
        final jitter = (rnd.nextDouble() - 0.5) * cellSize * 0.5;
        final dist = ((i + 0.5) * step + phase * 40) % length;
        final tangent = metric.getTangentForOffset(dist);
        if (tangent == null) continue;
        final normal = ui.Offset(-tangent.vector.dy, tangent.vector.dx);
        final center = tangent.position + normal * jitter;
        // Fade in/out near the wrap point instead of teleporting back to
        // the start of the path at full brightness.
        final glint = riverFlowGlintMetrics(
          phase: phase,
          index: i,
          dist: dist,
          length: length,
        );
        canvas.drawCircle(
          center,
          1.2 + glint.pulse * 1.6,
          glintPaint
            ..color = const ui.Color(0xFFf2ffff)
                .withValues(alpha: 0.28 * glint.pulse * glint.edgeFade),
        );
      }
    }

    // Gentle expanding ripple rings (soft/blurred, not crisp arcs).
    final rippleCount = (length / (cellSize * 2.4)).floor().clamp(0, 80);
    if (rippleCount == 0) continue;
    final rippleRnd = Random(23);
    final rippleStep = length / rippleCount;
    for (var i = 0; i < rippleCount; i++) {
      final baseDist = (i + 0.5) * rippleStep;
      const cycle = 3.2;
      final t = ((phase + i * 0.7) % cycle) / cycle;
      final dist = (baseDist + rippleRnd.nextDouble() * cellSize) % length;
      final tangent = metric.getTangentForOffset(dist);
      if (tangent == null) continue;
      // Fade in then out across the ring's whole lifetime, not just out.
      final ripple = riverFlowRippleMetrics(t: t, cellSize: cellSize);
      ripplePaint
        ..strokeWidth = 1.2
        ..color = const ui.Color(0xFFe8fbff).withValues(alpha: ripple.alpha);
      canvas.drawCircle(tangent.position, ripple.radius, ripplePaint);
    }
  }
}
