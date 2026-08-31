import 'dart:math';

/// Random delay before a `MobileUnitComponent` next re-evaluates/recomputes
/// its movement path.
double spawnRepathDelay() => 0.5 + Random().nextDouble() * 0.3;
