import 'dart:math';

/// A small sideways offset for one tree's canopy, driven by a sine wave
/// over elapsed [phase] seconds and scaled by [windStrength] (0..1). The
/// phase offset is derived from the tree's own cell (not [Random], which
/// is reserved for placement/jitter) so it stays fixed across frames and
/// makes a whole forest sway out of sync instead of snapping side to side
/// in lockstep.
double treeSway({
  required int col,
  required int row,
  required double windStrength,
  required double phase,
}) {
  if (windStrength <= 0) return 0;
  final offset = ((col * 13 + row * 31) % 100) / 100.0 * 2 * pi;
  return sin(phase * 1.6 + offset) * windStrength.clamp(0, 1) * 6.0;
}
