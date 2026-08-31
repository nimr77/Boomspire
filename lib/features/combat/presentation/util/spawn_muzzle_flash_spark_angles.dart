import 'dart:math';

/// Random spark angles for a `MuzzleFlashComponent`'s radiating sparks.
List<double> spawnMuzzleFlashSparkAngles() {
  final rnd = Random();
  return List.generate(5, (_) => rnd.nextDouble() * 2 * pi);
}
