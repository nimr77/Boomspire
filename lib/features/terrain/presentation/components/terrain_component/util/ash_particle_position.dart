import 'dart:math';

AshParticlePosition ashParticlePosition({
  required double randBaseX,
  required double randBaseY,
  required double randBobPhase,
  required double width,
  required double height,
  required double weatherPhase,
  required double drift,
}) {
  final baseX = randBaseX * width;
  final baseY = randBaseY * height;
  final bobPhase = randBobPhase * pi * 2;
  final x = (baseX + drift) % width;
  final y = (baseY + sin(weatherPhase * 0.8 + bobPhase) * 10) % height;
  return (x: x, y: y);
}

/// Looping drifted position for one ash particle (fleck or smudge) in
/// `TerrainComponent._paintWindStreaks`, given already-drawn random values
/// (so the caller's [Random] draw order/count stays unchanged).
typedef AshParticlePosition = ({double x, double y});
