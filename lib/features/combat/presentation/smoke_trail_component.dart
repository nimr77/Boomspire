import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_smoke_trail.dart';

/// Short-lived puff left behind a flying rocket.
class SmokeTrailComponent extends PositionComponent {
  static const _duration = 0.4;

  double _age = 0;
  SmokeTrailComponent({required Vector2 position})
    : super(position: position, anchor: Anchor.center);

  @override
  void render(Canvas canvas) =>
      paintSmokeTrail(canvas, age: _age, duration: _duration);

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
