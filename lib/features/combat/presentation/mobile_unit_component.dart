import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/attackable.dart';
import '../../../core/combat/mobile_unit_blueprint.dart';
import '../../../core/combat/movement_style.dart';
import '../../../core/combat/team.dart';
import '../../../core/combat/unit.dart';
import '../../../core/combat/weapon_type.dart';
import '../../../core/pathfinding/astar.dart';
import '../../../core/rendering/model_loader.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../game_core/domain/models/game_status.dart';
import '../../game_core/presentation/boomspire_game.dart';
import 'bullet_component.dart';
import 'cartoon_poof_component.dart';
import 'explosion_component.dart';
import 'fire_pulse_component.dart';
import 'impact_spark_component.dart';
import 'laser_beam_component.dart';
import 'muzzle_flash_component.dart';
import 'rocket_component.dart';
import 'smoke_trail_component.dart';
import 'vapor_cone_component.dart';

/// Shared base for every mobile (non-tower) combat unit - both the AI-enemy
/// invaders (`EnemyComponent`) and the player-buildable ally units
/// (`AllyUnitComponent`) extend this instead of duplicating movement,
/// targeting, firing and death logic. What actually differs between the two
/// sides is captured by a handful of small overridable hooks (what counts
/// as "the enemy", where to head next, what happens on arrival/death) -
/// everything else (path following/flight, weapon-type firing effects,
/// health bar, vehicle death FX) is written once here and simply tinted
/// with the unit's [Team.color].
abstract class MobileUnitComponent extends PositionComponent
    with HasGameReference<BoomspireGame>, Unit
    implements Attackable {
  final MobileUnitBlueprint blueprint;
  final Team team;

  double health;

  List<Vector2> _path = [];
  int _pathIndex = 0;
  double _repathTimer = 0;
  double _attackCooldown = 0;
  Attackable? _engaging;
  double _bobPhase = Random().nextDouble() * pi * 2;
  double _vaporTimer = 0;
  double _preExplosionTimer = 0;
  bool _destroyed = false;
  late final PositionComponent _visual;

  MobileUnitComponent({
    required this.blueprint,
    required this.team,
    super.position,
  }) : health = blueprint.maxHealth,
       super(
         size: Vector2.all(blueprint.size),
         anchor: Anchor.center,
         priority: team.isEnemy ? 10 : 9,
       );

  @override
  Set<UnitDomain> get attackDomains => blueprint.attackDomains;

  @override
  bool get destroyed => _destroyed;

  /// Multiplies [MobileUnitBlueprint.attackRange] when scanning for
  /// something to engage - used by the enemy side's "clear obstacles"
  /// directive to make units eager to detour toward a tower that isn't
  /// directly in their path yet.
  double get detectionRangeMultiplier => 1.0;

  @override
  UnitDomain get domain => blueprint.domain;

  /// Current attack damage, after any side-specific scaling.
  double get effectiveAttackDamage => blueprint.attackDamage;

  /// Current max health, after any side-specific scaling (ally units scale
  /// with the level of the building that produced them - see
  /// `AllyUnitComponent`).
  double get effectiveMaxHealth => blueprint.maxHealth;

  @override
  double get healthRatio => (health / effectiveMaxHealth).clamp(0.0, 1.0);

  /// Whether this unit ever stops to trade fire at all right now - the
  /// enemy AI director can order a "rush the base" wave where nothing
  /// engages defenses no matter how close they are.
  bool get ignoresEngagement => false;

  /// Vehicles on the enemy side telegraph an impending death with sparking
  /// smoke at low HP - kept off by default (ally vehicles just fight to
  /// the end) since it was never part of the ally side's original design.
  bool get showsLowHealthTelegraph => false;

  /// Hook for subclasses to attach extra always-on visuals (spinning
  /// rotors, blinking lights, etc.) once [_visual] is loaded.
  Future<void> addExtraVisuals(PositionComponent visual) async {}

  /// Blends a raw direction with a short-range separation push away from
  /// nearby units of the same side/domain, so a crowd converging on the
  /// same point flows around itself instead of stacking - only the enemy
  /// side does this today (see `EnemyComponent`).
  Vector2 applySeparationSteering(Vector2 dir) => dir;

  Future<Sprite> buildSprite();

  /// Where this unit should head toward right now - a fixed objective for
  /// enemies rushing the base, the nearest live target for allies hunting
  /// enemies. Null means "hold position".
  Vector2? goalPosition();

  /// Forces this unit onto a specific starting position before its first
  /// path is computed (enemies spawn at a random terrain spawn point) -
  /// null means "keep whatever position it was constructed with" (allies
  /// are placed at their producing building).
  Vector2? initialPosition() => null;

  /// Called right after this unit's own death FX are spawned - enemies
  /// award kill gold here, allies do nothing extra.
  void onDeath() {}

  @override
  Future<void> onLoad() async {
    final spawn = initialPosition();
    if (spawn != null) position = spawn;
    if (!isAirUnit) {
      final goal = goalPosition();
      if (goal != null) _computePath(goal);
    }

    _visual = await ModelLoader.loadOrFallback(
      key: '${team.isEnemy ? 'enemy' : 'ally'}_${blueprint.kind.name}',
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
      game.audioRepository.play(
        SfxType.vehicleEngine,
        volume: team.isEnemy ? 0.5 : 0.4,
      );
    }
  }

  /// Called once this unit reaches [goalPosition] with nothing left to
  /// engage - enemies escape past the base and damage the player, allies
  /// just hold and wait for a new target next frame.
  void onReachGoal() {}

  /// Everything this unit's weapon might stop and engage instead of
  /// continuing toward [goalPosition] - towers+allies for enemies, enemies
  /// only for allies.
  Iterable<Attackable> opposingTargets();

  /// Removes this unit from whichever typed roster (`GameWorld.
  /// activeEnemies`/`activeAllies`) it was spawned into.
  void removeSelf();

  @override
  void render(Canvas canvas) {
    if (health >= effectiveMaxHealth) return;
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
      Paint()..color = team.color,
    );
  }

  /// Lower is better - the "closest wins" default (used by allies and most
  /// enemy focus hints). Enemy overrides this to chase the weakest tower or
  /// to strongly prefer towers/structures over ally units when directed to
  /// clear obstacles.
  double scoreFor(Attackable candidate, double distance) => distance;

  @override
  void takeDamage(double amount) {
    if (_destroyed || isRemoving) return;
    health -= amount;
    if (health <= 0) _die();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_destroyed) return;
    if (game.gameState.status != GameStatus.playing) return;

    if (blueprint.isVehicle && showsLowHealthTelegraph && healthRatio < 0.3) {
      _preExplosionTimer -= dt;
      if (_preExplosionTimer <= 0) {
        _preExplosionTimer = 0.35 + Random().nextDouble() * 0.3;
        game.world.spawn(
          SmokeTrailComponent(position: position.clone() + Vector2(0, -6)),
        );
      }
    }

    if (_maybeEngage(dt)) {
      _applyBob(dt);
      return;
    }

    final goal = goalPosition();
    if (goal != null) {
      if (isAirUnit) {
        _flyToward(goal, dt);
      } else {
        _repathTimer -= dt;
        if (_repathTimer <= 0) _computePath(goal);
        _followPath(dt);
      }
    }
    _applyBob(dt);
  }

  void _applyBob(double dt) {
    _bobPhase += dt * (blueprint.movementStyle == MovementStyle.roll ? 6 : 10);
    switch (blueprint.movementStyle) {
      case MovementStyle.walk:
        _visual.position = size / 2 + Vector2(0, sin(_bobPhase) * 1.5);
      case MovementStyle.roll:
        _visual.position = size / 2;
        _visual.angle += sin(_bobPhase) * 0.05;
      case MovementStyle.hover:
        _visual.position = size / 2 + Vector2(0, sin(_bobPhase) * 2.5);
      case MovementStyle.swoop:
        _visual.position = size / 2;
        _visual.angle += sin(_bobPhase * 0.5) * 0.08;
      case MovementStyle.sail:
        _visual.position = size / 2 + Vector2(0, sin(_bobPhase) * 2);
        _visual.angle = sin(_bobPhase * 0.5) * 0.06;
    }
  }

  void _computePath(Vector2 goal) {
    final grid = game.terrainMap.grid;
    final startCell = grid.worldToCell(position);
    final goalCell = grid.worldToCell(goal);
    final cells = AStarPathFinder.findPath(grid, startCell, goalCell);
    _path = (cells ?? [goalCell]).map(grid.cellCenter).toList();
    _pathIndex = 0;
    _repathTimer = 0.9 + Random().nextDouble() * 0.6;
  }

  void _die() {
    _destroyed = true;
    if (blueprint.isVehicle) {
      game.audioRepository.play(
        SfxType.vehicleExplosion,
        volume: team.isEnemy ? 0.6 : 0.5,
      );
      game.world.spawn(
        ExplosionComponent(
          position: position.clone(),
          radius: size.x * (team.isEnemy ? 0.9 : 0.85),
        ),
      );
    } else {
      game.audioRepository.play(
        SfxType.soldierPop,
        volume: team.isEnemy ? 0.5 : 0.4,
      );
      game.world.spawn(CartoonPoofComponent(position: position.clone()));
    }
    onDeath();
    removeSelf();
  }

  Attackable? _findTargetInRange() {
    Attackable? best;
    var bestScore = double.infinity;
    final maxDist = blueprint.attackRange * detectionRangeMultiplier;
    for (final candidate in opposingTargets()) {
      if (candidate.destroyed) continue;
      if (!canAttack(candidate.domain)) continue;
      final d = candidate.position.distanceTo(position);
      if (d > maxDist) continue;
      final score = scoreFor(candidate, d);
      if (score < bestScore) {
        best = candidate;
        bestScore = score;
      }
    }
    return best;
  }

  void _fireAt(Attackable target, Vector2 toTarget) {
    final spawnPos = position + toTarget.normalized() * (size.x / 2);
    final damage = effectiveAttackDamage;
    game.shakeCamera(power: damage, origin: position.clone());
    final accent = team.color;
    switch (blueprint.weaponType) {
      case WeaponType.bullet:
        game.world.spawn(
          BulletComponent(
            start: spawnPos,
            target: target,
            damage: damage,
            fromEnemy: team.isEnemy,
          ),
        );
        game.audioRepository.play(
          team.isEnemy ? SfxType.enemyShot : SfxType.machineGunShot,
          volume: 0.3,
        );
      case WeaponType.cannon:
        game.world.spawn(
          RocketComponent(
            start: spawnPos,
            target: target,
            damage: damage,
            splashRadius: 44,
            bodyColor: const Color(0xFF6D4C41),
            tipColor: accent,
            affectsTowers: team.isEnemy,
          ),
        );
        game.audioRepository.play(SfxType.cannonShot, volume: 0.5);
      case WeaponType.rocket:
        game.world.spawn(
          RocketComponent(
            start: spawnPos,
            target: target,
            damage: damage,
            splashRadius: 60,
            bodyColor: const Color(0xFFB0BEC5),
            tipColor: accent,
            affectsTowers: team.isEnemy,
          ),
        );
        game.audioRepository.play(SfxType.rocketLaunch, volume: 0.5);
      case WeaponType.laser:
        target.takeDamage(damage);
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
          damage: damage,
        ),
      ),
    );
  }

  void _flyToward(Vector2 target, double dt) {
    final toTarget = target - position;
    final dist = toTarget.length;
    final step = blueprint.speed * dt;
    if (dist <= step) {
      position += toTarget;
      onReachGoal();
      return;
    }
    final dir = applySeparationSteering(toTarget / dist);
    position += dir * step;
    _visual.angle = atan2(dir.y, dir.x) + pi / 2;

    if (blueprint.movementStyle == MovementStyle.swoop) {
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
      onReachGoal();
      return;
    }
    final target = _path[_pathIndex];
    final toTarget = target - position;
    final dist = toTarget.length;
    final step = blueprint.speed * dt;

    if (dist <= step) {
      position.setFrom(target);
      _pathIndex++;
      if (_pathIndex >= _path.length) onReachGoal();
    } else {
      final dir = applySeparationSteering(toTarget / dist);
      position += dir * step;
      _visual.angle = atan2(dir.y, dir.x) + pi / 2;
    }
  }

  bool _maybeEngage(double dt) {
    if (blueprint.attackDamage <= 0) return false;
    if (ignoresEngagement) {
      _engaging = null;
      return false;
    }

    if (_engaging != null && (_engaging!.destroyed || !_engaging!.isMounted)) {
      _engaging = null;
    }
    _engaging ??= _findTargetInRange();
    final target = _engaging;
    if (target == null) return false;

    final toTarget = target.position - position;
    _visual.angle = atan2(toTarget.y, toTarget.x) + pi / 2;

    _attackCooldown -= dt;
    if (_attackCooldown <= 0) {
      _attackCooldown = blueprint.attackInterval;
      _fireAt(target, toTarget);
    }
    return true;
  }
}
