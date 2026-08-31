import 'dart:math';

SnowFlakeMetrics snowFlakeMetrics({
  required double randBaseX,
  required double randBaseY,
  required double randDriftPhase,
  required double randSpeedMul,
  required double randRadius,
  required double randAlpha,
  required double randSway,
  required double width,
  required double height,
  required double weatherPhase,
  required double fallSpeed,
  required double windStrength,
}) {
  final baseX = randBaseX * width;
  final baseY = randBaseY * height;
  final driftPhase = randDriftPhase * pi * 2;
  final speedMul = 0.6 + randSpeedMul * 0.7;
  final y = (baseY + weatherPhase * fallSpeed * speedMul) % height;
  final sway =
      sin(weatherPhase * (1 + speedMul * 0.4) + driftPhase) *
      (5 + randSway * 10 + windStrength * 14);
  final x = (baseX + sway) % width;
  return (
    x: x,
    y: y,
    radius: 1.0 + randRadius * 1.4,
    alpha: 0.45 + randAlpha * 0.4,
  );
}

/// Computed position/size/style for one falling snowflake in
/// `TerrainComponent._paintSnow`, given already-drawn random values (so the
/// caller's [Random] draw order/count stays unchanged).
typedef SnowFlakeMetrics = ({double x, double y, double radius, double alpha});
