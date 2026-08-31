import 'dart:math';

/// Random starting phase for a `TowerComponent`'s idle breathing/pulse
/// animation, so towers don't all pulse in lockstep.
double spawnTowerIdlePhase() => Random().nextDouble() * pi * 2;
