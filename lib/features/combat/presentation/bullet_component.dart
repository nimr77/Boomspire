import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/targetable.dart';
import '../../game_core/presentation/boomspire_game.dart';
import 'impact_spark_component.dart';

/// Fast tracer round - flies straight toward wherever [target] was standing
/// the instant it was fired ([_aimPoint], snapshotted once) and applies
/// direct damage on impact. Deliberately NOT homing: it doesn't curve to
/// chase a target that keeps moving, and if the target dies mid-flight it
/// keeps flying to that same spot (and just skips the damage) instead of
/// vanishing on the spot it happened to be at when the target disappeared.
/// Used by both towers (yellow tracer) and enemies (red tracer) via
/// [fromEnemy].
class BulletComponent extends PositionComponent
    with HasGameReference<BoomspireGame> {
  static const _speed = 640.0;

  final Targetable target;
  final double damage;
  final bool fromEnemy;

  /// Where [target] was standing the moment this round was fired - the
  /// fixed impact point this bullet flies straight toward, see class doc.
  final Vector2 _aimPoint;
  BulletComponent({
    required Vector2 start,
    required this.target,
    required this.damage,
    this.fromEnemy = false,
  }) : _aimPoint = target.position.clone(),
       super(position: start, size: Vector2(11, 3), anchor: Anchor.center);

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
    final toTarget = _aimPoint - position;
    final dist = toTarget.length;
    angle = atan2(toTarget.y, toTarget.x);
    final step = _speed * dt;
    if (dist <= step) {
      if (target.isMounted && !target.isRemoving) {
        target.takeDamage(damage);
      }
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
