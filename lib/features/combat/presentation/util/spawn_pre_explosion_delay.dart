import 'dart:math';

/// Random delay before a low-health vehicle's next pre-explosion smoke
/// puff.
double spawnPreExplosionDelay() => 0.35 + Random().nextDouble() * 0.3;
