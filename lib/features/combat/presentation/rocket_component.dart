import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../enemies/presentation/enemy_component.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../game_core/presentation/circuit_defense_game.dart';
import 'explosion_component.dart';
import 'smoke_trail_component.dart';

/// Slower homing rocket that leaves a smoke trail and detonates into a
/// splash-damage explosion on arrival.
class RocketComponent extends PositionComponent
    with HasGameReference<CircuitDefenseGame> {
  RocketComponent({
    required Vector2 start,
    required this.target,
    required this.damage,
    required this.splashRadius,
  }) : super(position: start, size: Vector2(15, 5), anchor: Anchor.center);

  final EnemyComponent target;
  final double damage;
  final double splashRadius;
  static const _speed = 340.0;
  double _trailTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _trailTimer -= dt;
    if (_trailTimer <= 0) {
      _trailTimer = 0.03;
      game.world.spawn(SmokeTrailComponent(position: position.clone()));
    }

    final aimPoint = (target.isMounted && !target.isRemoving)
        ? target.position
        : position;
    final toTarget = aimPoint - position;
    final dist = toTarget.length;
    angle = atan2(toTarget.y, toTarget.x);

    final step = _speed * dt;
    if (dist <= step || target.isRemoving || !target.isMounted) {
      _detonate();
      return;
    }
    position += toTarget.normalized() * step;
  }

  void _detonate() {
    game.audioRepository.play(SfxType.explosion, volume: 0.8);
    game.world.spawn(
      ExplosionComponent(position: position.clone(), radius: splashRadius),
    );
    for (final enemy in List.of(game.world.activeEnemies)) {
      if (enemy.position.distanceTo(position) <= splashRadius) {
        enemy.takeDamage(damage);
      }
    }
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFB0BEC5),
    );
    canvas.drawCircle(
      Offset(size.x - 2, size.y / 2),
      2.6,
      Paint()..color = const Color(0xFFFF7043),
    );
  }
}
