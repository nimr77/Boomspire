import 'dart:ui';

import 'package:flame/components.dart';

import 'util/cartoon_poof_particles.dart';
import 'util/paint_cartoon_poof.dart';

/// A silly, non-gory "cartoon pop" for a defeated soldier - a squash pop of
/// cream-colored smoke, a few flailing limb-shaped scraps, and spinning
/// yellow stars, instead of a serious explosion.
class CartoonPoofComponent extends PositionComponent {
  static const _duration = 0.5;

  double _age = 0;
  late final List<CartoonPoofScrap> _scraps;
  late final List<CartoonPoofStar> _stars;

  CartoonPoofComponent({required Vector2 position})
    : super(position: position, anchor: Anchor.center, priority: 20);

  @override
  Future<void> onLoad() async {
    final particles = spawnCartoonPoofParticles();
    _scraps = particles.scraps;
    _stars = particles.stars;
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final fade = 1 - t;
    paintCartoonPoof(canvas, t: t, fade: fade, scraps: _scraps, stars: _stars);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
