import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_rotor.dart';

/// Always-spinning main rotor blur disc, layered above a helicopter-kind
/// unit's static fuselage sprite so it reads as "alive" even while idling -
/// attached via `MobileUnitComponent.addExtraVisuals`.
class RotorComponent extends PositionComponent {
  double _spin = 0;

  RotorComponent({required Vector2 position})
    : super(
        position: position + Vector2(0, -position.y * 0.7),
        anchor: Anchor.center,
        size: Vector2.all(position.x * 1.9),
        priority: 5,
      );

  @override
  void render(Canvas canvas) => paintRotor(canvas, size: size, spin: _spin);

  @override
  void update(double dt) {
    super.update(dt);
    _spin += dt * 18;
  }
}
