import 'dart:math';

VolcanicLakeEmberMetrics volcanicLakeEmberMetrics({
  required int index,
  required double phase,
  required double baseY,
}) {
  final rise = ((phase * 26 + index * 41) % 70);
  return (y: baseY - rise * 0.35, alpha: sin(pi * (rise / 70)).clamp(0.0, 1.0));
}

/// Risen y-position and fade alpha for one ember drifting up out of a
/// volcanic lake in `TerrainPainter.paintVolcanicLakeFlow` - fades in then
/// out across its rise so nothing pops in/out at full brightness.
typedef VolcanicLakeEmberMetrics = ({double y, double alpha});
