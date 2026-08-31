import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_fire_pulse.dart';

/// A flat ground-level shockwave ring that flashes under a unit the instant
/// it fires, tinted to that unit's faction color. Sized from the shot's
/// power and range so heavier/longer-ranged weapons leave a bigger pulse.
class FirePulseComponent extends PositionComponent {
  static const _duration = 0.32;

  final Color color;
  final double maxRadius;

  double _age = 0;
  FirePulseComponent({
    required Vector2 position,
    required this.color,
    required this.maxRadius,
  }) : super(position: position, anchor: Anchor.center, priority: 2);

  @override
  void render(Canvas canvas) => paintFirePulse(
    canvas,
    age: _age,
    duration: _duration,
    maxRadius: maxRadius,
    color: color,
  );

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  /// Derives a pulse radius from a weapon's range and damage - "the size of
  /// the firing" - clamped to a sane on-screen range.
  static double radiusFor({required double range, required double damage}) {
    return (16 + range * 0.12 + damage * 0.3).clamp(16.0, 90.0);
  }
}
