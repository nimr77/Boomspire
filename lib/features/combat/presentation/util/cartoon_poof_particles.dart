import 'dart:math';

import 'package:flame/components.dart';

/// Random scrap/star burst data for `CartoonPoofComponent` - one shared
/// `Random()` sequence (scraps generated first, then stars), matching the
/// original single-pass spawn order.
({List<CartoonPoofScrap> scraps, List<CartoonPoofStar> stars})
spawnCartoonPoofParticles() {
  final rnd = Random();
  final scraps = List.generate(5, (_) {
    final a = rnd.nextDouble() * 2 * pi;
    final speed = 30 + rnd.nextDouble() * 40;
    return CartoonPoofScrap(
      Vector2(cos(a), sin(a)) * speed,
      rnd.nextDouble() * 2 * pi,
      6 + rnd.nextDouble() * 4,
    );
  });
  final stars = List.generate(4, (i) {
    final a = i * (pi / 2) + rnd.nextDouble() * 0.6;
    return CartoonPoofStar(
      Vector2(cos(a), sin(a)) * (24 + rnd.nextDouble() * 18),
    );
  });
  return (scraps: scraps, stars: stars);
}

/// One flailing limb-shaped scrap flung outward from a cartoon poof.
class CartoonPoofScrap {
  final Vector2 velocity;
  final double spin;
  final double length;
  CartoonPoofScrap(this.velocity, this.spin, this.length);
}

/// One spinning star flung outward from a cartoon poof.
class CartoonPoofStar {
  final Vector2 velocity;
  CartoonPoofStar(this.velocity);
}
