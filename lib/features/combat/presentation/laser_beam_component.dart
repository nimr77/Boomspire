import 'dart:ui';

import 'package:flame/components.dart';

/// A short-lived, instantly-hitting energy beam drawn as a bright core line
/// with a soft glow, from a tower straight to its target. Unlike
/// [BulletComponent], damage is already applied by the firer the instant the
/// beam spawns - this is purely the visual.
class LaserBeamComponent extends PositionComponent {
  static const _duration = 0.09;

  final Vector2 start;
  final Vector2 end;
  final Color color;
  double _age = 0;

  LaserBeamComponent({
    required this.start,
    required this.end,
    required this.color,
  }) : super(priority: 22);

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final fade = 1 - t;
    final from = Offset(start.x, start.y);
    final to = Offset(end.x, end.y);

    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = color.withValues(alpha: 0.35 * fade)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.9 * fade)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
