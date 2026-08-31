import 'dart:math';
import 'dart:ui' as ui;

import 'lifecycle_fade.dart';
import 'wave_crest_path.dart';

/// Live per-frame glassy shimmer for still water (lakes): soft blurred
/// glints drift slowly across the surface and gentle ripple rings expand
/// and fade - the stillwater counterpart to `paintRiverFlowOverlay`'s
/// directional flow, clipped to [shape] so nothing bleeds past the
/// shoreline.
void paintLakeFlowOverlay(
  ui.Canvas canvas,
  ui.Path shape,
  double cellSize,
  double phase,
) {
  final bounds = shape.getBounds();
  if (bounds.width <= 0 || bounds.height <= 0) return;
  canvas.save();
  canvas.clipPath(shape);

  // Glassy wave crests drifting slowly across the pond - a gentle sine
  // wobble along each band's length so it reads as an actual rolling
  // wave instead of a flat straight stripe, and fades in/out smoothly
  // across its whole sweep so it never just pops into/out of view.
  final diag = bounds.width + bounds.height;
  final bandPaint = ui.Paint()
    ..style = ui.PaintingStyle.stroke
    ..strokeCap = ui.StrokeCap.round
    ..strokeJoin = ui.StrokeJoin.round
    ..strokeWidth = cellSize * 0.35
    ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 9);
  for (var i = 0; i < 4; i++) {
    final seedRnd = Random(211 + i);
    final t = ((phase * 0.05) + i / 4) % 1.0;
    final dist = t * diag * 1.4 - bounds.height;
    // Linear fade in/out across the WHOLE drift (not a sine hump that
    // plateaus near the middle and only visibly fades right at the
    // very end) so brightness keeps changing the entire time it's alive.
    final fade = lifecycleFade(t);
    if (fade <= 0.01) continue;
    bandPaint.color = const ui.Color(0xFFeafbff).withValues(alpha: 0.14 * fade);
    canvas.drawPath(
      waveCrestPath(
        bounds: bounds,
        dist: dist,
        amplitude: cellSize * (0.35 + seedRnd.nextDouble() * 0.25),
        wavelength: cellSize * (2.0 + seedRnd.nextDouble() * 1.2),
        wobblePhase: phase * 1.3 + i * 2.1,
      ),
      bandPaint,
    );
  }

  // Small shimmering glints scattered across the surface - each has its
  // own life cycle (fade in, peak, fade out on a straight linear ramp
  // the whole time, not a blink between a dim and bright floor) and
  // stays soft/blurred instead of a hard-edged dot.
  final rnd = Random(29);
  for (var i = 0; i < 12; i++) {
    final gx = bounds.left + rnd.nextDouble() * bounds.width;
    final gy = bounds.top + rnd.nextDouble() * bounds.height;
    final seedRnd = Random(311 + i);
    final cycle = 3.0 + seedRnd.nextDouble() * 2.5;
    final t = ((phase + i * 1.7) % cycle) / cycle;
    final pulse = lifecycleFade(t);
    canvas.drawCircle(
      ui.Offset(gx, gy),
      1.0 + pulse * 1.8,
      ui.Paint()
        ..color = const ui.Color(0xFFffffff).withValues(alpha: 0.32 * pulse)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3.5),
    );
  }

  // Gentle expanding ripple rings that loop endlessly.
  for (var i = 0; i < 5; i++) {
    final seedRnd = Random(101 + i);
    final cx = bounds.left + seedRnd.nextDouble() * bounds.width;
    final cy = bounds.top + seedRnd.nextDouble() * bounds.height;
    const cycle = 4.0;
    final t = ((phase + i * 0.9) % cycle) / cycle;
    final radius = t * cellSize * 2.4;
    // Linear fade in then out across the ring's whole lifetime, not a
    // sine hump that only visibly changes right at the very end.
    final alpha = lifecycleFade(t) * 0.22;
    canvas.drawCircle(
      ui.Offset(cx, cy),
      radius,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = const ui.Color(0xFFeafbff).withValues(alpha: alpha)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3.5),
    );
  }

  canvas.restore();
}
