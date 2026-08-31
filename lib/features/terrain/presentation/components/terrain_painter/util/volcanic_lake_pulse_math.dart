import 'dart:math';

VolcanicLakePulse volcanicLakePulse(double phase) {
  final pulse = 0.5 + 0.5 * sin(phase * 2.0);
  return (value: pulse, alpha: 0.06 + pulse * 0.05);
}

/// Pulsing glow strength (and its fill alpha) for a volcanic lake's
/// ambient glow in `TerrainPainter.paintVolcanicLakeFlow`.
typedef VolcanicLakePulse = ({double value, double alpha});
