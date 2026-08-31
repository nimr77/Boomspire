/// Looping drifted x-position for one non-ash wind-streak particle in
/// `TerrainComponent._paintWindStreaks`, given the already-drawn random
/// value (so the caller's [Random] draw order/count stays unchanged).
double windStreakParticleX({
  required double randBaseX,
  required double width,
  required double drift,
}) => (randBaseX * width + drift) % width;
