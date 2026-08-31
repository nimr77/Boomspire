import 'dart:math';
import 'dart:ui' as ui;

/// Traces one diagonal, sine-wavy "wave crest" line sweeping across
/// [bounds] - shared by `TerrainPainter.paintLakeFlow`/`paintSeaFlow` so a
/// drifting highlight band reads as an actual rolling wave (a gentle
/// sideways wobble along its length) instead of a flat straight stripe.
ui.Path waveCrestPath({
  required ui.Rect bounds,
  required double dist,
  required double amplitude,
  required double wavelength,
  required double wobblePhase,
}) {
  final path = ui.Path();
  const steps = 24;
  for (var s = 0; s <= steps; s++) {
    final f = s / steps;
    final baseX = bounds.left + dist - bounds.height * f;
    final baseY = bounds.top + bounds.height * f;
    final wobble =
        sin(f * bounds.height / wavelength * 2 * pi + wobblePhase) *
        amplitude;
    final offset = ui.Offset(baseX + wobble, baseY);
    if (s == 0) {
      path.moveTo(offset.dx, offset.dy);
    } else {
      path.lineTo(offset.dx, offset.dy);
    }
  }
  return path;
}
