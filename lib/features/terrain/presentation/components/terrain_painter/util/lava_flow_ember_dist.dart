/// Wrapped travel distance for one rising ember along the lava flow in
/// `TerrainPainter.paintLavaFlow`, so embers drift along the channel
/// instead of clustering at one spot.
double lavaFlowEmberDist({
  required double baseDist,
  required double randJitter,
  required double cellSize,
  required double length,
}) => (baseDist + randJitter * cellSize * 0.4) % length;
