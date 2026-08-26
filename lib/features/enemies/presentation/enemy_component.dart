import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/targetable.dart';
import '../../../core/pathfinding/astar.dart';
import '../../../core/rendering/model_loader.dart';
import '../../ai_director/domain/models/strategy_directive.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/bullet_component.dart';
import '../../combat/presentation/cartoon_poof_component.dart';
import '../../combat/presentation/explosion_component.dart';
import '../../combat/presentation/fire_pulse_component.dart';
import '../../combat/presentation/impact_spark_component.dart';
import '../../combat/presentation/laser_beam_component.dart';
import '../../combat/presentation/muzzle_flash_component.dart';
import '../../combat/presentation/rocket_component.dart';
import '../../combat/presentation/smoke_trail_component.dart';
import '../../combat/presentation/vapor_cone_component.dart';
import '../../game_core/domain/models/game_status.dart';
import '../../game_core/presentation/circuit_defense_game.dart';
import '../../towers/presentation/tower_component.dart';
import '../domain/models/enemy_blueprint.dart';
import '../domain/models/enemy_movement_style.dart';
import '../domain/models/enemy_weapon_type.dart';
import 'enemy_sprites.dart';
import 'floating_text_component.dart';

/// Base enemy: ground types path-find across the whole terrain (routing
/// around mountains and towers), flyers ignore obstacles and beeline for the
/// base. Any enemy with an attack stat will stop to shoot a tower blocking
/// its way. Resolves death/escape (gold reward or player damage) once it
/// reaches its goal or is destroyed.
abstract class EnemyComponent extends PositionComponent
    with HasGameReference<CircuitDefenseGame>
    implements Targetable {
  final EnemyBlueprint blueprint;

  /// Enemies within this squared distance of each other push apart a bit
  /// (see [_steer]) instead of overlapping/stacking while converging on the
  /// same path or base.
  static const _separationRadiusSq = 26.0 * 26.0;

  double health;
  List<Vector2> _path = [];

  int _pathIndex = 0;
  double _repathTimer = 0;
  double _attackCooldown = 0;
  TowerComponent? _engaging;
  double _bobPhase = Random().nextDouble() * pi * 2;
  double _vaporTimer = 0;
  double _preExplosionTimer = 0;
  late final PositionComponent _visual;
  EnemyComponent({required this.blueprint})
    : health = blueprint.maxHealth,
      super(
        size: Vector2.all(blueprint.size),
        anchor: Anchor.center,
        priority: 10,
      );

  /// Hook for subclasses to attach extra always-on visuals (spinning rotors,
  /// blinking lights, etc.) once [_visual] is loaded.
  Future<void> addExtraVisuals(PositionComponent visual) async {}

  Future<Sprite> buildSprite();

  @override
  Future<void> onLoad() async {
    final spawnPoints = game.terrainMap.spawnPoints;
    final sp = spawnPoints[Random().nextInt(spawnPoints.length)];
    final jitter = (Random().nextDouble() - 0.5) * 60;
    position = Vector2(sp.x, sp.y + jitter);

    if (!blueprint.isFlying) _computePath();

    _visual = await ModelLoader.loadOrFallback(
      key: 'enemy_${blueprint.type.name}',
      size: size,
      fallback: () async => SpriteComponent(
        sprite: await buildSprite(),
        size: size,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
    _visual
      ..anchor = Anchor.center
      ..position = size / 2;
    await add(_visual);
    await addExtraVisuals(_visual);
    if (blueprint.isVehicle) {
      game.audioRepository.play(SfxType.vehicleEngine, volume: 0.5);
    }
  }

  @override
  void render(Canvas canvas) {
    if (health >= blueprint.maxHealth) return;
    final ratio = (health / blueprint.maxHealth).clamp(0.0, 1.0);
    final barWidth = size.x * 0.8;
    final barX = (size.x - barWidth) / 2;
    const barY = -8.0;
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

  @override
  void takeDamage(double amount) {
    if (isRemoving) return;
    health -= amount;
    if (health <= 0) _die();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState.status != GameStatus.playing) return;

    if (blueprint.isVehicle && health / blueprint.maxHealth < 0.3) {
      _preExplosionTimer -= dt;
      if (_preExplosionTimer <= 0) {
        _preExplosionTimer = 0.35 + Random().nextDouble() * 0.3;
        game.world.spawn(
          SmokeTrailComponent(position: position.clone() + Vector2(0, -6)),
        );
      }
    }

    if (_maybeEngageTower(dt)) return;

    if (blueprint.isFlying) {
      _flyToward(
        Vector2(game.terrainMap.basePoint.x, game.terrainMap.basePoint.y),
        dt,
      );
    } else {
      _repathTimer -= dt;
      if (_repathTimer <= 0) _computePath();
      _followPath(dt);
    }

    _bobPhase +=
        dt * (blueprint.movementStyle == EnemyMovementStyle.roll ? 6 : 10);
    switch (blueprint.movementStyle) {
      case EnemyMovementStyle.walk:
        _visual.position = size / 2 + Vector2(0, sin(_bobPhase) * 1.5);
      case EnemyMovementStyle.roll:
        _visual.position = size / 2;
        _visual.angle += sin(_bobPhase) * 0.05;
      case EnemyMovementStyle.hover:
        _visual.position = size / 2 + Vector2(0, sin(_bobPhase) * 2.5);
      case EnemyMovementStyle.swoop:
        _visual.position = size / 2;
        _visual.angle += sin(_bobPhase * 0.5) * 0.08;
    }
  }

  void _computePath() {
    final grid = game.terrainMap.grid;
    final startCell = grid.worldToCell(position);
    final goalCell = grid.worldToCell(
      Vector2(game.terrainMap.basePoint.x, game.terrainMap.basePoint.y),
    );
    final cells = AStarPathFinder.findPath(grid, startCell, goalCell);
    _path = (cells ?? [goalCell]).map(grid.cellCenter).toList();
    _pathIndex = 0;
    _repathTimer = 1.0 + Random().nextDouble() * 0.6;
  }

  void _die() {
    final reward = blueprint.bounty + (game.gameState.currentWave - 1) * 2;
    game.gameState.addGold(reward);
    if (blueprint.isVehicle) {
      game.audioRepository.play(SfxType.vehicleExplosion, volume: 0.6);
      game.world.spawn(
        ExplosionComponent(position: position.clone(), radius: size.x * 0.9),
      );
    } else {
      game.audioRepository.play(SfxType.soldierPop, volume: 0.5);
      game.world.spawn(CartoonPoofComponent(position: position.clone()));
    }
    game.audioRepository.play(SfxType.goldGain, volume: 0.35);
    game.world.spawn(
      FloatingTextComponent(
        text: '+${reward}g',
        position: position.clone() + Vector2(0, -size.y / 2 - 4),
      ),
    );
    game.world.removeEnemy(this);
  }

  void _escape() {
    game.gameState.damagePlayer(1);
    game.audioRepository.play(SfxType.enemyEscape, volume: 0.5);
    game.world.removeEnemy(this);
  }

  TowerComponent? _findTowerInRange() {
    final hint = game.enemyFocusHint;
    final maxDist = hint == FocusHint.rushBase
        ? blueprint.attackRange * 0.5
        : blueprint.attackRange;

    TowerComponent? best;
    var bestScore = double.infinity;
    for (final tower in game.world.activeTowers) {
      if (tower.destroyed) continue;
      final d = tower.position.distanceTo(position);
      if (d > maxDist) continue;
      // "Score" is what we minimize: distance for nearest-tower/rush-base
      // targeting, remaining HP ratio (scaled small so ties break on
      // distance) when the director wants weak towers focused down first.
      final score = hint == FocusHint.weakestTower ? tower.hp / tower.maxHp : d;
      if (score < bestScore) {
        best = tower;
        bestScore = score;
      }
    }
    return best;
  }

  void _flyToward(Vector2 target, double dt) {
    final toTarget = target - position;
    final dist = toTarget.length;
    final step = blueprint.speed * dt;
    if (dist <= step) {
      _escape();
      return;
    }
    final dir = _steer(toTarget / dist);
    position += dir * step;
    _visual.angle = atan2(dir.y, dir.x) + pi / 2;

    // Fast fixed-wing units visibly "break the air" behind them as they cut
    // across the battlefield at speed.
    if (blueprint.movementStyle == EnemyMovementStyle.swoop) {
      _vaporTimer -= dt;
      if (_vaporTimer <= 0) {
        _vaporTimer = 0.07;
        game.world.spawn(
          VaporConeComponent(
            position: position.clone() - dir * (size.x * 0.5),
            angle: atan2(dir.y, dir.x),
          ),
        );
      }
    }
  }

  void _followPath(double dt) {
    if (_pathIndex >= _path.length) {
      _escape();
      return;
    }
    final target = _path[_pathIndex];
    final toTarget = target - position;
    final dist = toTarget.length;
    final step = blueprint.speed * dt;

    if (dist <= step) {
      position.setFrom(target);
      _pathIndex++;
      if (_pathIndex >= _path.length) _escape();
    } else {
      final dir = _steer(toTarget / dist);
      position += dir * step;
      _visual.angle = atan2(dir.y, dir.x) + pi / 2;
    }
  }

  /// Blends the raw path/beeline direction with a short-range separation
  /// push away from nearby enemies of the same domain (ground vs air don't
  /// need to avoid each other) - without this, enemies converging on the
  /// same waypoint/base pile up directly on top of one another instead of
  /// flowing around each other like a real crowd would.
  Vector2 _steer(Vector2 dir) {
    final separation = Vector2.zero();
    for (final other in game.world.activeEnemies) {
      if (identical(other, this)) continue;
      if (other.blueprint.isFlying != blueprint.isFlying) continue;
      final delta = position - other.position;
      final distSq = delta.length2;
      if (distSq > 0 && distSq < _separationRadiusSq) {
        separation.add(delta / distSq);
      }
    }
    if (separation.isZero()) return dir;
    final blended = dir + separation.normalized() * 0.5;
    return blended.isZero() ? dir : blended.normalized();
  }

  bool _maybeEngageTower(double dt) {
    if (blueprint.attackDamage <= 0) return false;
    // When the director orders a base rush, this unit ignores defenses
    // entirely - no stopping to trade shots, straight for the home base.
    if (game.enemyFocusHint == FocusHint.rushBase) {
      _engaging = null;
      return false;
    }

    if (_engaging != null && (_engaging!.destroyed || !_engaging!.isMounted)) {
      _engaging = null;
    }
    _engaging ??= _findTowerInRange();
    final target = _engaging;
    if (target == null) return false;

    final toTarget = target.position - position;
    _visual.angle = atan2(toTarget.y, toTarget.x) + pi / 2;

    _attackCooldown -= dt;
    if (_attackCooldown <= 0) {
      _attackCooldown = blueprint.attackInterval;
      final spawnPos = position + toTarget.normalized() * (size.x / 2);
      game.shakeCamera(power: blueprint.attackDamage, origin: position.clone());
      final accent = EnemySpriteFactory.accentColor(blueprint.type);
      switch (blueprint.weaponType) {
        case EnemyWeaponType.bullet:
          game.world.spawn(
            BulletComponent(
              start: spawnPos,
              target: target,
              damage: blueprint.attackDamage,
              fromEnemy: true,
            ),
          );
          game.audioRepository.play(SfxType.enemyShot, volume: 0.3);
        case EnemyWeaponType.cannon:
          game.world.spawn(
            RocketComponent(
              start: spawnPos,
              target: target,
              damage: blueprint.attackDamage,
              splashRadius: 44,
              bodyColor: const Color(0xFF6D4C41),
              tipColor: const Color(0xFFFFAB40),
              affectsTowers: true,
            ),
          );
          game.audioRepository.play(SfxType.cannonShot, volume: 0.5);
        case EnemyWeaponType.rocket:
          game.world.spawn(
            RocketComponent(
              start: spawnPos,
              target: target,
              damage: blueprint.attackDamage,
              splashRadius: 60,
              bodyColor: const Color(0xFFB0BEC5),
              tipColor: const Color(0xFFFF5252),
              affectsTowers: true,
            ),
          );
          game.audioRepository.play(SfxType.rocketLaunch, volume: 0.5);
        case EnemyWeaponType.laser:
          target.takeDamage(blueprint.attackDamage);
          game.world.spawn(
            LaserBeamComponent(
              start: spawnPos,
              end: target.position.clone(),
              color: accent,
            ),
          );
          game.world.spawn(
            ImpactSparkComponent(
              position: target.position.clone(),
              color: accent,
            ),
          );
          game.audioRepository.play(SfxType.laserShot, volume: 0.4);
      }
      game.world.spawn(MuzzleFlashComponent(position: spawnPos));
      game.world.spawn(
        FirePulseComponent(
          position: position.clone(),
          color: accent,
          maxRadius: FirePulseComponent.radiusFor(
            range: blueprint.attackRange,
            damage: blueprint.attackDamage,
          ),
        ),
      );
    }
    return true;
  }
}
