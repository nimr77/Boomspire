import 'dart:math';

/// Random starting phase (0..2π) for a periodic animation - shared by a
/// `MobileUnitComponent`'s bob/idle pulse phases and a strafing plane's
/// loiter-circle start angle.
double spawnRandomPhase() => Random().nextDouble() * pi * 2;
