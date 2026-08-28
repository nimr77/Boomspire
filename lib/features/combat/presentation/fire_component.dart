import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

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
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final fade = 1 - t;
    if (fade <= 0) return;
    final wobble = sin(_flicker * 9) * size.x * 0.06;
    final h = size.x * (0.55 + sin(_flicker * 7) * 0.08);
    // Flame's render box is top-left-origin, so the flame must be built
    // around (cx, cy) rather than (0, 0) to sit on the impact point.
    final cx = size.x / 2;
    final cy = size.y / 2;
    final path = Path()
      ..moveTo(cx, cy + size.x * 0.3)
      ..quadraticBezierTo(
        cx + size.x * 0.28 + wobble,
        cy + size.x * 0.05,
        cx,
        cy - h,
      )
      ..quadraticBezierTo(
        cx - size.x * 0.28 + wobble,
        cy + size.x * 0.05,
        cx,
        cy + size.x * 0.3,
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Color.lerp(
          const Color(0xFFFF7043),
          const Color(0x00FF7043),
          t,
        )!.withValues(alpha: 0.85 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      Offset(cx, cy + size.x * 0.28),
      size.x * 0.22 * fade,
      Paint()..color = const Color(0x66000000).withValues(alpha: 0.4 * fade),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    _flicker += dt;
    if (_age >= _duration) removeFromParent();
  }
}
