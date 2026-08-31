import 'dart:math';

LavaFlowGlowMetrics lavaFlowGlowMetrics({
  required double phase,
  required double cellSize,
}) {
  final pulse = 0.5 + 0.5 * sin(phase * 2.2);
  return (
    pulse: pulse,
    strokeWidth: cellSize * (0.5 + pulse * 0.15),
    alpha: 0.35 + pulse * 0.25,
  );
}

/// Pulsing brightness/stroke-width/alpha for the lava ribbon's main glow
/// stroke in `TerrainPainter.paintLavaFlow`.
typedef LavaFlowGlowMetrics = ({
  double pulse,
  double strokeWidth,
  double alpha,
});
