import 'dart:ui';

import 'package:flame/components.dart';

/// Quick bright flash at a tower's muzzle when it fires.
class MuzzleFlashComponent extends PositionComponent {
  MuzzleFlashComponent({required Vector2 position})
    : super(position: position, anchor: Anchor.center, priority: 25);

  double _age = 0;
  static const _duration = 0.06;

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
      8 * (1 - t),
      Paint()
        ..color = Color.lerp(
          const Color(0xFFFFF6D8),
          const Color(0x00FFB703),
          t,
        )!,
    );
  }
}
