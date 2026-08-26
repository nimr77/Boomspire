import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../enemies/presentation/enemy_component.dart';
import '../../game_core/presentation/circuit_defense_game.dart';

/// Fast machine-gun tracer round - flies straight to its target and applies
/// direct damage on impact.
class BulletComponent extends PositionComponent
    with HasGameReference<CircuitDefenseGame> {
  BulletComponent({
    required Vector2 start,
    required this.target,
    required this.damage,
  }) : super(position: start, size: Vector2(11, 3), anchor: Anchor.center);

  final EnemyComponent target;
  final double damage;
  static const _speed = 640.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (target.isRemoving || !target.isMounted) {
      removeFromParent();
      return;
    }
    final toTarget = target.position - position;
    final dist = toTarget.length;
    angle = atan2(toTarget.y, toTarget.x);
    final step = _speed * dt;
    if (dist <= step) {
      target.takeDamage(damage);
      removeFromParent();
      return;
    }
    position += toTarget.normalized() * step;
  }

  @override
  void render(Canvas canvas) {
    final glow = Paint()
      ..color = const Color(0x55FFD54A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 5, glow);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFFFD54A),
    );
  }
}
