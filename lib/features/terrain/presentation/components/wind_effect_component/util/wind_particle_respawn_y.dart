import 'dart:math';

final _rnd = Random();

/// A newly randomized Y for a wind particle that just wrapped past the
/// arena's left edge - kept as a single persistent (unseeded) generator
/// rather than a fresh [Random] per call, matching the original
/// per-instance `Random()` field's continuously-advancing behavior.
double windParticleRespawnY(double arenaHeight) =>
    _rnd.nextDouble() * arenaHeight;
