import 'dart:math';

/// Random lateral jitter applied to a base-rushing unit's spawn offset, so
/// units from the same wave don't all spawn on the exact same point.
double spawnBaseRushJitter() => (Random().nextDouble() - 0.5) * 60;

/// Picks a random terrain spawn point index out of [count] available
/// spawn points.
int spawnRandomSpawnPointIndex(int count) => Random().nextInt(count);
