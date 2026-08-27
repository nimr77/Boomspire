import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;

import '../../../core/combat/attackable.dart';
import '../../../core/pathfinding/astar.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/bullet_component.dart';
import '../../combat/presentation/cartoon_poof_component.dart';
import '../../combat/presentation/explosion_component.dart';
import '../../combat/presentation/impact_spark_component.dart';
import '../../combat/presentation/rocket_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import '../../game_core/domain/models/game_status.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../domain/models/ally_movement_style.dart';
import '../domain/models/ally_unit_blueprint.dart';

/// The home base's signature cyan - every friendly unit is tinted with this
/// color (in its sprite art and its HP bar) so it reads as "ours" at a
/// glance, the same way `HomeBaseComponent` reads as home turf.
const Color kHomeAccentColor = Color(0xFF00E5FF);

/// A unit produced by the Training Center or War Factory: unlike a tower,
/// it isn't tied to a grid cell - it walks/flies out and hunts down the
/// nearest enemy on the map, engaging it in a direct firefight, mirroring
/// how `EnemyComponent` engages towers.
abstract class AllyUnitComponent extends PositionComponent
    with HasGameReference<BoomspireGame>
    implements Attackable {
  final AllyUnitBlueprint blueprint;

  double health;
  List<Vector2> _path = [];
  int _pathIndex = 0;
  double _repathTimer = 0;
  double _attackCooldown = 0;
  EnemyComponent? _engaging;
  double _bobPhase = Random().nextDouble() * pi * 2;
  bool _destroyed = false;
  late final PositionComponent _visual;

  AllyUnitComponent({required this.blueprint, required Vector2 position})
    : health = blueprint.maxHealth,
      super(
        position: position,
        size: Vector2.all(blueprint.size),
        anchor: Anchor.center,
        priority: 9,
      );

  @override
  bool get destroyed => _destroyed;

  @override
  double get healthRatio => (health / blueprint.maxHealth).clamp(0.0, 1.0);

  Future<Sprite> buildSprite();

  @override
  Future<void> onLoad() async {
    _visual = SpriteComponent(
      sprite: await buildSprite(),
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    await add(_visual);
    if (blueprint.isVehicle) {
      game.audioRepository.play(SfxType.vehicleEngine, volume: 0.4);
    }

    // "Alive" build-in, matching the tower spawn pop.
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.25, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    if (health >= blueprint.maxHealth) return;
    final ratio = healthRatio;
    final barWidth = size.x * 0.8;
    final barX = (size.x - barWidth) / 2;
    const barY = -8.0;
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth, 4),
      Paint()..color = const Color(0xAA000000),
    );
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth * ratio, 4),
      Paint()..color = kHomeAccentColor,
    );
  }

  @override
  void takeDamage(double amount) {
    if (_destroyed) return;
    health -= amount;
    if (health <= 0) _die();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_destroyed) return;
    if (game.gameState.status != GameStatus.playing) return;

    if (_maybeEngageEnemy(dt)) {
      _bob(dt);
      return;
    }

    final seek = _nearestEnemy();
    if (seek == null) return;

    if (blueprint.isFlying) {
      _flyToward(seek.position, dt);
    } else {
      _repathTimer -= dt;
      if (_repathTimer <= 0) _computePathTo(seek.position);
      _followPath(dt);
    }
    _bob(dt);
  }

  void _bob(double dt) {
    _bobPhase +=
        dt * (blueprint.movementStyle == AllyMovementStyle.roll ? 6 : 10);
    switch (blueprint.movementStyle) {
      case AllyMovementStyle.walk:
        _visual.position = size / 2 + Vector2(0, sin(_bobPhase) * 1.5);
      case AllyMovementStyle.roll:
        _visual.position = size / 2;
        _visual.angle += sin(_bobPhase) * 0.05;
      case AllyMovementStyle.swoop:
        _visual.position = size / 2;
        _visual.angle += sin(_bobPhase * 0.5) * 0.08;
    }
  }

  void _computePathTo(Vector2 goal) {
    final grid = game.terrainMap.grid;
    final startCell = grid.worldToCell(position);
    final goalCell = grid.worldToCell(goal);
    final cells = AStarPathFinder.findPath(grid, startCell, goalCell);
    _path = (cells ?? [goalCell]).map(grid.cellCenter).toList();
    _pathIndex = 0;
    _repathTimer = 0.8 + Random().nextDouble() * 0.5;
  }

  void _die() {
    _destroyed = true;
    if (blueprint.isVehicle) {
      game.audioRepository.play(SfxType.vehicleExplosion, volume: 0.5);
      game.world.spawn(
        ExplosionComponent(position: position.clone(), radius: size.x * 0.85),
      );
    } else {
      game.audioRepository.play(SfxType.soldierPop, volume: 0.4);
      game.world.spawn(CartoonPoofComponent(position: position.clone()));
    }
    game.world.removeAlly(this);
  }

  EnemyComponent? _findEnemyInRange() {
    EnemyComponent? best;
    var bestDist = blueprint.attackRange;
    for (final enemy in game.world.activeEnemies) {
      if (enemy.isRemoving) continue;
      final d = enemy.position.distanceTo(position);
      if (d <= bestDist) {
        best = enemy;
        bestDist = d;
      }
    }
    return best;
  }

  void _flyToward(Vector2 target, double dt) {
    final toTarget = target - position;
    final dist = toTarget.length;
    final step = blueprint.speed * dt;
    if (dist <= step) {
      position += toTarget;
      return;
    }
    final dir = toTarget / dist;
    position += dir * step;
    _visual.angle = atan2(dir.y, dir.x) + pi / 2;
  }

  void _followPath(double dt) {
    if (_pathIndex >= _path.length) return;
    final target = _path[_pathIndex];
    final toTarget = target - position;
    final dist = toTarget.length;
    final step = blueprint.speed * dt;

    if (dist <= step) {
      position.setFrom(target);
      _pathIndex++;
    } else {
      final dir = toTarget / dist;
      position += dir * step;
      _visual.angle = atan2(dir.y, dir.x) + pi / 2;
    }
  }

  bool _maybeEngageEnemy(double dt) {
    if (_engaging != null && (_engaging!.isRemoving || !_engaging!.isMounted)) {
      _engaging = null;
    }
    _engaging ??= _findEnemyInRange();
    final target = _engaging;
    if (target == null) return false;

    final toTarget = target.position - position;
    _visual.angle = atan2(toTarget.y, toTarget.x) + pi / 2;

    _attackCooldown -= dt;
    if (_attackCooldown <= 0) {
      _attackCooldown = blueprint.attackInterval;
      final spawnPos = position + toTarget.normalized() * (size.x / 2);
      if (blueprint.isVehicle) {
        game.world.spawn(
          RocketComponent(
            start: spawnPos,
            target: target,
            damage: blueprint.attackDamage,
            splashRadius: 40,
            bodyColor: const Color(0xFF37474F),
            tipColor: kHomeAccentColor,
          ),
        );
        game.audioRepository.play(SfxType.rocketLaunch, volume: 0.4);
      } else {
        game.world.spawn(
          BulletComponent(
            start: spawnPos,
            target: target,
            damage: blueprint.attackDamage,
          ),
        );
        game.audioRepository.play(SfxType.machineGunShot, volume: 0.3);
      }
      game.world.spawn(
        ImpactSparkComponent(
          position: spawnPos.clone(),
          color: kHomeAccentColor,
        ),
      );
    }
    return true;
  }

  EnemyComponent? _nearestEnemy() {
    EnemyComponent? best;
    var bestDist = double.infinity;
    for (final enemy in game.world.activeEnemies) {
      if (enemy.isRemoving) continue;
      final d = enemy.position.distanceTo(position);
      if (d < bestDist) {
        best = enemy;
        bestDist = d;
      }
    }
    return best;
  }
}
