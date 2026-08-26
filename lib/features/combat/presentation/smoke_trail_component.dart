import 'dart:ui';

import 'package:flame/components.dart';

/// Short-lived puff left behind a flying rocket.
class SmokeTrailComponent extends PositionComponent {
  SmokeTrailComponent({required Vector2 position})
    : super(position: position, anchor: Anchor.center);

  double _age = 0;
  static const _duration = 0.4;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset.zero,
      5 + t * 6,
      Paint()
        ..color = Color.lerp(
          const Color(0xAA9E9E9E),
          const Color(0x009E9E9E),
          t,
        )!,
    );
  }
}
