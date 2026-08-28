import 'dart:ui';

import 'package:flame/components.dart';

/// A tread print stamped into the ground behind a heavy (tracked) vehicle -
/// unlike the light vehicle's [DustPuffComponent] this lingers for a while
/// so a driven-over path visibly reads as tracks on the map.
class TrackMarkComponent extends PositionComponent {
  static const _duration = 7.0;

  double _age = 0;

  TrackMarkComponent({required Vector2 position, required double angle})
    : super(
        position: position,
        anchor: Anchor.center,
        angle: angle,
        priority: -1,
      );

  @override
  void render(Canvas canvas) {
    final fade = (1 - _age / _duration).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = const Color(0xFF2B2B2B).withValues(alpha: 0.35 * fade);
    for (final dx in [-6.0, 6.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(dx, 0), width: 5, height: 14),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
