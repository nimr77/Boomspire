import 'dart:math';
import 'dart:ui' as ui;

import 'lifecycle_fade.dart';
import 'wave_crest_path.dart';

/// Live per-frame open-ocean wave overlay for the "sea" biome's main
/// water body (as opposed to a contained pond): several long,
/// sine-wavy wave crests roll across the whole sea, plus scattered
/// shimmering glints and gentle expanding ripples - the same
/// glassy-shimmer vocabulary as `paintLakeFlowOverlay`, scaled up and
/// clipped to [shape] (the arena minus any reef/islet land) instead of a
/// single pond, so open water finally reads as moving rather than a flat
/// static tint.
void paintSeaFlowOverlay(
  ui.Canvas canvas,
  ui.Path shape,
  double cellSize,
  double phase,
) {
  final bounds = shape.getBounds();
  if (bounds.width <= 0 || bounds.height <= 0) return;
  canvas.save();
  canvas.clipPath(shape);

  // Long rolling wave crests sweeping diagonally across the whole sea,
  // each fading in/out smoothly across its own sweep rather than
  // popping in/out at the edges.
  const waveCount = 6;
  final diag = bounds.width + bounds.height;
  final wavePaint = ui.Paint()
    ..style = ui.PaintingStyle.stroke
    ..strokeCap = ui.StrokeCap.round
    ..strokeJoin = ui.StrokeJoin.round
    ..strokeWidth = cellSize * 0.4
    ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10);
  for (var i = 0; i < waveCount; i++) {
    final seedRnd = Random(511 + i);
    final speed = 0.035 + seedRnd.nextDouble() * 0.02;
    final t = ((phase * speed) + i / waveCount) % 1.0;
    final dist = t * diag * 1.3 - bounds.height;
    // Linear fade across the WHOLE sweep - see `lifecycleFade`.
    final fade = lifecycleFade(t);
    if (fade <= 0.01) continue;
    wavePaint.color = const ui.Color(0xFFeafbff).withValues(alpha: 0.14 * fade);
    canvas.drawPath(
      waveCrestPath(
        bounds: bounds,
        dist: dist,
        amplitude: cellSize * (0.5 + seedRnd.nextDouble() * 0.4),
        wavelength: cellSize * (2.5 + seedRnd.nextDouble() * 1.5),
        wobblePhase: phase * 1.2 + i * 1.9,
      ),
      wavePaint,
    );
  }

  // Small shimmering glints scattered across the surface, each on its
  // own life cycle - see `lifecycleFade`.
  final rnd = Random(733);
  final glintCount =
      ((bounds.width * bounds.height) / (cellSize * cellSize * 6))
          .floor()
          .clamp(20, 220);
  for (var i = 0; i < glintCount; i++) {
    final gx = bounds.left + rnd.nextDouble() * bounds.width;
    final gy = bounds.top + rnd.nextDouble() * bounds.height;
    final seedRnd = Random(1301 + i);
    final cycle = 3.0 + seedRnd.nextDouble() * 2.5;
    final t = ((phase + i * 1.4) % cycle) / cycle;
    final pulse = lifecycleFade(t);
    canvas.drawCircle(
      ui.Offset(gx, gy),
      1.0 + pulse * 1.6,
      ui.Paint()
        ..color = const ui.Color(0xFFffffff).withValues(alpha: 0.28 * pulse)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3.5),
    );
  }

  // Gentle expanding ripple rings scattered across the sea, looping
  // endlessly and fading in then out across their whole lifetime (a
  // linear ramp, not a sine hump) so none of them ever just vanishes
  // mid-ring.
  final ringCount = (glintCount / 6).round().clamp(4, 36);
  for (var i = 0; i < ringCount; i++) {
    final seedRnd = Random(901 + i);
    final cx = bounds.left + seedRnd.nextDouble() * bounds.width;
    final cy = bounds.top + seedRnd.nextDouble() * bounds.height;
    final cycle = 4.0 + seedRnd.nextDouble() * 2.0;
    final t = ((phase + i * 0.7) % cycle) / cycle;
    final radius = t * cellSize * 3.0;
    final alpha = lifecycleFade(t) * 0.2;
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
