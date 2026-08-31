import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_vapor_cone.dart';

/// A single frame of the "breaking the air" streak a fast fixed-wing enemy
/// leaves behind it - a short, fading vapor cone aligned to its heading.
class VaporConeComponent extends PositionComponent {
  static const _duration = 0.35;

  final double coneAngle;
  double _age = 0;

  VaporConeComponent({required Vector2 position, required double angle})
    : coneAngle = angle,
      super(position: position, anchor: Anchor.center, priority: 3);

  @override
  void render(Canvas canvas) => paintVaporCone(
    canvas,
    age: _age,
    duration: _duration,
    coneAngle: coneAngle,
  );

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
