import 'dart:math';

RiverFlowBandMetrics riverFlowBandMetrics({
  required double phase,
  required double dist,
  required double cellSize,
  required double start,
  required double end,
  required double bandLen,
}) {
  final wobble = sin(phase * 1.4 + dist * 0.02) * cellSize * 0.12;
  final visibleFraction = ((end - start) / bandLen).clamp(0.0, 1.0);
  final strokeWidth = cellSize * (0.5 + 0.08 * sin(phase + dist * 0.01));
  return (
    wobble: wobble,
    visibleFraction: visibleFraction,
    strokeWidth: strokeWidth,
  );
}

/// Computed styling for one glassy highlight band drawn along the river
/// flow in `TerrainPainter.paintRiverFlow`: the sideways drift wobble, how
/// much of the band is currently visible (for a smooth fade in/out at the
/// clipped ends of its sweep), and the stroke width gently pulsing over
/// time.
typedef RiverFlowBandMetrics = ({
  double wobble,
  double visibleFraction,
  double strokeWidth,
});
