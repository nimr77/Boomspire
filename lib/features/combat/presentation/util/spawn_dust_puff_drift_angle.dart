import 'dart:math';

/// Random drift angle for a `DustPuffComponent`'s puff offset.
double spawnDustPuffDriftAngle() => Random().nextDouble() * 2 * pi;
