RainDropMetrics rainDropMetrics({
  required double randX,
  required double randBaseY,
  required double randSpeedMul,
  required double randLength,
  required double randAlpha,
  required double randStrokeWidth,
  required double width,
  required double height,
  required double weatherPhase,
  required double fallSpeed,
}) {
  final x = randX * width;
  final baseY = randBaseY * height;
  final speedMul = 0.7 + randSpeedMul * 0.5;
  final length = 5 + randLength * 4;
  final y = (baseY + weatherPhase * fallSpeed * speedMul) % height;
  return (
    x: x,
    y: y,
    length: length,
    alpha: 0.2 + randAlpha * 0.22,
    strokeWidth: 0.7 + randStrokeWidth * 0.5,
    speedMul: speedMul,
  );
}

/// Computed position/style for one falling rain streak in
/// `TerrainComponent._paintRain`, given already-drawn random values (so the
/// caller's [Random] draw order/count stays unchanged) plus the frame's
/// elapsed [weatherPhase].
typedef RainDropMetrics = ({
  double x,
  double y,
  double length,
  double alpha,
  double strokeWidth,
  double speedMul,
});
