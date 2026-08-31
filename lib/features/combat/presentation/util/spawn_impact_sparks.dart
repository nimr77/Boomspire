import 'dart:math';

import 'package:flame/components.dart';

/// Random spark burst velocities for an `ImpactSparkComponent`.
List<Vector2> spawnImpactSparks() {
  final rnd = Random();
  return List.generate(6, (_) {
    final a = rnd.nextDouble() * 2 * pi;
    final speed = 10 + rnd.nextDouble() * 14;
    return Vector2(cos(a), sin(a)) * speed;
  });
}
