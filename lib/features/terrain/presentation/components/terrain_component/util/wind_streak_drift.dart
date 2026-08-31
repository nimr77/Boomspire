/// How far the wind-streak/ash particle field has scrolled sideways by
/// [weatherPhase], scaled by [windStrength] - shared drift driving both the
/// ash and non-ash branches of `TerrainComponent._paintWindStreaks`.
double windStreakDrift({
  required double weatherPhase,
  required double windStrength,
}) => weatherPhase * (30 + windStrength * 70);
