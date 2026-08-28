import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Light dust kicked up behind a wheeled (light) vehicle - fades quickly
/// and leaves nothing behind, unlike [TrackMarkComponent].
class DustPuffComponent extends PositionComponent {
  static const _duration = 0.6;

  double _age = 0;
  final double _driftAngle = Random().nextDouble() * 2 * pi;

  DustPuffComponent({required Vector2 position})
    : super(position: position, anchor: Anchor.center, priority: -1);

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(cos(_driftAngle), sin(_driftAngle)) * (t * 6),
      4 + t * 5,
      Paint()
        ..color = Color.lerp(
          const Color(0x66C9B183),
          const Color(0x00C9B183),
          t,
        )!,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
