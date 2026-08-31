import 'dart:math';

RiverFlowRippleMetrics riverFlowRippleMetrics({
  required double t,
  required double cellSize,
}) {
  final radius = t * cellSize * 0.9;
  final alpha = sin(pi * t).clamp(0.0, 1.0) * 0.22;
  return (radius: radius, alpha: alpha);
}

/// Radius and fade-alpha for one expanding ripple ring at lifetime
/// fraction [t] in `[0, 1]`, used by `TerrainPainter.paintRiverFlow`'s
/// gentle ripple overlay.
typedef RiverFlowRippleMetrics = ({double radius, double alpha});
