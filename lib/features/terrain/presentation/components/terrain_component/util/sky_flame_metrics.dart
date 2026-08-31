import 'dart:math';

SkyFlameMetrics skyFlameMetrics({
  required int index,
  required double randX,
  required double randBaseY,
  required double randFrequency,
  required double randRadius,
  required double randColor,
  required double width,
  required double height,
  required double weatherPhase,
}) {
  final x = randX * width;
  final baseY = height * (0.04 + randBaseY * 0.16);
  final pulse =
      0.6 + 0.4 * sin(weatherPhase * (0.4 + randFrequency * 0.5) + index);
  final radius = (28 + randRadius * 42) * pulse;
  return (
    x: x,
    y: baseY,
    radius: radius,
    alpha: 0.16 * pulse,
    colorT: randColor,
  );
}

/// Computed position/size/style for one drifting sky-flame glow blob in
/// `TerrainComponent._paintSkyFlames`, given already-drawn random values
/// (so the caller's [Random] draw order/count stays unchanged).
typedef SkyFlameMetrics = ({
  double x,
  double y,
  double radius,
  double alpha,
  double colorT,
});
