import 'dart:math';

import 'package:flame/components.dart';

import '../../enemies/presentation/enemy_component.dart';
import '../../game_core/presentation/circuit_defense_game.dart';
import '../../terrain/domain/models/build_slot.dart';
import '../domain/models/tower_blueprint.dart';
import 'tower_sprites.dart';

/// Base tower: sits on a [BuildSlot], scans for the nearest enemy in range,
/// swivels its turret to face it, and fires on cooldown.
abstract class TowerComponent extends PositionComponent
    with HasGameReference<CircuitDefenseGame> {
  TowerComponent({required this.slot, required this.blueprint})
    : super(
        position: Vector2(slot.x, slot.y),
        size: Vector2.all(slot.size),
        anchor: Anchor.center,
        priority: 5,
      );

  final BuildSlot slot;
  final TowerBlueprint blueprint;

  double _cooldown = 0;
  late final PositionComponent turret;

  @override
  Future<void> onLoad() async {
    final baseSprite = SpriteComponent(
      sprite: await TowerSpriteFactory.base(blueprint.type),
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    await add(baseSprite);

    turret = PositionComponent(anchor: Anchor.center, position: size / 2)
      ..add(
        SpriteComponent(
          sprite: await TowerSpriteFactory.turret(blueprint.type),
          size: size * 0.75,
          anchor: Anchor.center,
        ),
      );
    await add(turret);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _cooldown -= dt;

    final target = _acquireTarget();
    if (target == null) return;

    final toTarget = target.position - position;
    final desiredAngle = atan2(toTarget.y, toTarget.x) + pi / 2;
    turret.angle = _turnToward(turret.angle, desiredAngle, dt * 8);

    if (_cooldown <= 0) {
      fire(target);
      _cooldown = blueprint.fireRate;
    }
  }

  EnemyComponent? _acquireTarget() {
    EnemyComponent? closest;
    var closestDist = blueprint.range;
    for (final enemy in game.world.activeEnemies) {
      final d = enemy.position.distanceTo(position);
      if (d <= closestDist) {
        closest = enemy;
        closestDist = d;
      }
    }
    return closest;
  }

  double _turnToward(double current, double target, double maxDelta) {
    var diff = (target - current) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    if (diff < -pi) diff += 2 * pi;
    if (diff.abs() <= maxDelta) return target;
    return current + maxDelta * diff.sign;
  }

  /// Spawns the appropriate projectile/effect toward [target].
  void fire(EnemyComponent target);
}
