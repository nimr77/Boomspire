import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_explosion.dart';
import 'util/spawn_explosion_embers.dart';

/// Rocket impact: a bright expanding flash ring plus scattering embers,
/// scaled to the tower's splash radius.
class ExplosionComponent extends PositionComponent {
  static const _duration = 0.6;

  final double radius;
  double _age = 0;
  late final List<ExplosionEmber> _embers;
  ExplosionComponent({required Vector2 position, required this.radius})
    : super(position: position, anchor: Anchor.center, priority: 30);

  @override
  Future<void> onLoad() async {
    _embers = spawnExplosionEmbers(radius);
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    paintExplosion(
      canvas,
      t: t,
      age: _age,
      duration: _duration,
      radius: radius,
      embers: _embers,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
