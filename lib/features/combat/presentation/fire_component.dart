import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_fire.dart';

/// A lingering burning patch left by a rocket/shell impact - separate from
/// the instantaneous `ExplosionComponent` flash, this stays and flickers
/// for a few seconds so a rocket strike visibly "starts a fire".
class FireComponent extends PositionComponent {
  static const _duration = 3.0;

  double _flicker = 0;
  double _age = 0;

  FireComponent({required Vector2 position, double radius = 16})
    : super(
        position: position,
        anchor: Anchor.center,
        size: Vector2.all(radius * 2),
        priority: 2,
      );

  @override
  void render(Canvas canvas) => paintFire(
    canvas,
    size: size,
    age: _age,
    flicker: _flicker,
    duration: _duration,
  );

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    _flicker += dt;
    if (_age >= _duration) removeFromParent();
  }
}
