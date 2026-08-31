import 'dart:math';

import 'package:flame/components.dart';

/// Random ember scatter data for `ExplosionComponent`, scaled to [radius].
List<ExplosionEmber> spawnExplosionEmbers(double radius) {
  final rnd = Random();
  return List.generate(16, (_) {
    final a = rnd.nextDouble() * 2 * pi;
    final speed = radius * (0.6 + rnd.nextDouble() * 1.2);
    return ExplosionEmber(
      Vector2(cos(a), sin(a)) * speed,
      rnd.nextDouble() * 0.15,
    );
  });
}

/// One ember scattered outward from an explosion.
class ExplosionEmber {
  final Vector2 velocity;
  final double delay;
  ExplosionEmber(this.velocity, this.delay);
}
