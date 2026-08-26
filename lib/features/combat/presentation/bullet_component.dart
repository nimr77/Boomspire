import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/targetable.dart';
import '../../game_core/presentation/circuit_defense_game.dart';
import 'impact_spark_component.dart';

/// Fast tracer round - flies straight to its target and applies direct
/// damage on impact. Used by both towers (yellow tracer) and enemies (red
/// tracer) via [fromEnemy].
class BulletComponent extends PositionComponent
    with HasGameReference<CircuitDefenseGame> {
  static const _speed = 640.0;

  final Targetable target;
  final double damage;
  final bool fromEnemy;
  BulletComponent({
    required Vector2 start,
    required this.target,
    required this.damage,
    this.fromEnemy = false,
  }) : super(position: start, size: Vector2(11, 3), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final color = fromEnemy ? const Color(0xFFFF5252) : const Color(0xFFFFD54A);
    final glow = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 5, glow);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = color,
    );
  }

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
      game.world.spawn(
        ImpactSparkComponent(
          position: position.clone(),
          color: fromEnemy ? const Color(0xFFFF5252) : const Color(0xFFFFD54A),
        ),
      );
      removeFromParent();
      return;
    }
    position += toTarget.normalized() * step;
  }
}
