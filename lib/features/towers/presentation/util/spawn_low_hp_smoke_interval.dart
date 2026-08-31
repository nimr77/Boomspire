import 'dart:math';

/// Random interval before a low-HP `TowerComponent` spawns its next smoke
/// puff.
double spawnLowHpSmokeInterval() => 0.5 + Random().nextDouble() * 0.4;
