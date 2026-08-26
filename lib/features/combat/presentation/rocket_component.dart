import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/targetable.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../game_core/presentation/circuit_defense_game.dart';
import 'explosion_component.dart';
import 'smoke_trail_component.dart';

/// Slower homing rocket/shell that leaves a smoke trail and detonates into a
/// splash-damage explosion on arrival. Shared by the rocket battery and the
/// siege cannon (with different colors/impact damage).
class RocketComponent extends PositionComponent
    with HasGameReference<CircuitDefenseGame> {
  static const _speed = 340.0;

  final Targetable target;
  final double damage;
  final double splashRadius;
  final Color bodyColor;
  final Color tipColor;

  /// True for enemy-fired shells so splash also damages towers, not enemies.
  final bool affectsTowers;
  double _trailTimer = 0;
  RocketComponent({
    required Vector2 start,
    required this.target,
    required this.damage,
    required this.splashRadius,
    this.bodyColor = const Color(0xFFB0BEC5),
    this.tipColor = const Color(0xFFFF7043),
    this.affectsTowers = false,
  }) : super(position: start, size: Vector2(15, 5), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(2),
      ),
      Paint()..color = bodyColor,
    );
    canvas.drawCircle(
      Offset(size.x - 2, size.y / 2),
      2.6,
      Paint()..color = tipColor,
    );
  }

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
    game.shakeCamera(
      power: damage + splashRadius * 0.5,
      origin: position.clone(),
    );
    game.world.spawn(
      ExplosionComponent(position: position.clone(), radius: splashRadius),
    );
    if (affectsTowers) {
      for (final tower in List.of(game.world.activeTowers)) {
        if (tower.position.distanceTo(position) <= splashRadius) {
          tower.takeDamage(damage);
        }
      }
    } else {
      for (final enemy in List.of(game.world.activeEnemies)) {
        if (enemy.position.distanceTo(position) <= splashRadius) {
          enemy.takeDamage(damage);
        }
      }
    }
    removeFromParent();
  }
}
