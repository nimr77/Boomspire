import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/targetable.dart';
import '../../../core/rendering/model_loader.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/fire_pulse_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import '../../game_core/presentation/circuit_defense_game.dart';
import '../domain/models/tower_blueprint.dart';
import 'tower_sprites.dart';

/// Base tower: sits on a build cell, scans for the nearest valid enemy in
/// range, swivels its turret to face it, and fires on cooldown. Also tracks
/// structural HP - enemies can shoot towers down, and the player can repair
/// them for gold.
abstract class TowerComponent extends PositionComponent
    with HasGameReference<CircuitDefenseGame>
    implements Targetable {
  final TowerBlueprint blueprint;

  double hp;
  int col = 0;
  int row = 0;
  double _cooldown = 0;

  bool _destroyed = false;
  late final PositionComponent turret;
  TowerComponent({
    required Vector2 position,
    required double cellSize,
    required this.blueprint,
  }) : hp = blueprint.maxHp,
       super(
         position: position,
         size: Vector2.all(cellSize),
         anchor: Anchor.center,
         priority: 5,
       );

  bool get destroyed => _destroyed;

  /// Gold cost to fully repair from current HP - 0 once at full health.
  int get repairCost {
    final missing = blueprint.maxHp - hp;
    if (missing <= 0) return 0;
    return (missing / blueprint.maxHp * blueprint.cost * 0.6).ceil();
  }

  /// Spawns the appropriate projectile/effect toward [target].
  void fire(EnemyComponent target);

  @override
  Future<void> onLoad() async {
    final cell = game.terrainMap.grid.worldToCell(position);
    col = cell.x;
    row = cell.y;

    final baseSprite = await ModelLoader.loadOrFallback(
      key: 'tower_${blueprint.type.name}',
      size: size,
      fallback: () async => SpriteComponent(
        sprite: await TowerSpriteFactory.base(blueprint.type),
        size: size,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
    baseSprite
      ..anchor = Anchor.center
      ..position = size / 2;
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
  void render(Canvas canvas) {
    if (hp >= blueprint.maxHp) return;
    final ratio = (hp / blueprint.maxHp).clamp(0.0, 1.0);
    final barWidth = size.x * 0.85;
    final barX = (size.x - barWidth) / 2;
    const barY = -10.0;
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth, 4),
      Paint()..color = const Color(0xAA000000),
    );
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth * ratio, 4),
      Paint()
        ..color = ratio > 0.5
            ? const Color(0xFF4CAF50)
            : const Color(0xFFE53935),
    );
  }

  void repair(double amount) {
    if (_destroyed) return;
    hp = (hp + amount).clamp(0, blueprint.maxHp);
  }

  @override
  void takeDamage(double amount) {
    if (_destroyed) return;
    hp = (hp - amount).clamp(0, blueprint.maxHp);
    if (hp <= 0) _destroy();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_destroyed) return;
    _cooldown -= dt;

    final target = _acquireTarget();
    if (target == null) return;

    final toTarget = target.position - position;
    final desiredAngle = atan2(toTarget.y, toTarget.x) + pi / 2;
    turret.angle = _turnToward(turret.angle, desiredAngle, dt * 8);

    if (_cooldown <= 0) {
      fire(target);
      game.shakeCamera(power: blueprint.damage, origin: position.clone());
      game.world.spawn(
        FirePulseComponent(
          position: position.clone(),
          color: TowerSpriteFactory.accentColor(blueprint.type),
          maxRadius: FirePulseComponent.radiusFor(
            range: blueprint.range,
            damage: blueprint.damage,
          ),
        ),
      );
      _cooldown = blueprint.fireRate;
    }
  }

  EnemyComponent? _acquireTarget() {
    EnemyComponent? closest;
    var closestDist = blueprint.range;
    for (final enemy in game.world.activeEnemies) {
      if (enemy.blueprint.isFlying && !blueprint.canTargetAir) continue;
      if (!enemy.blueprint.isFlying && !blueprint.canTargetGround) continue;
      final d = enemy.position.distanceTo(position);
      if (d <= closestDist) {
        closest = enemy;
        closestDist = d;
      }
    }
    return closest;
  }

  void _destroy() {
    _destroyed = true;
    game.audioRepository.play(SfxType.towerDestroyed, volume: 0.7);
    game.terrainMap.grid.setTowerOccupied(col, row, false);
    game.world.removeTower(this);
  }

  double _turnToward(double current, double target, double maxDelta) {
    var diff = (target - current) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    if (diff < -pi) diff += 2 * pi;
    if (diff.abs() <= maxDelta) return target;
    return current + maxDelta * diff.sign;
  }
}
