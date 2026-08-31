import 'dart:math';

/// Random jagged-kink side (+1 or -1) for a `LaserBeamComponent`'s bolt.
double spawnLaserBeamKinkSide() => Random().nextBool() ? 1.0 : -1.0;
