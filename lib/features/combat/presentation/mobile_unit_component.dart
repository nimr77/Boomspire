import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;

import '../../../core/combat/attackable.dart';
import '../../../core/combat/enums/unit_body_type.dart';
import '../../../core/combat/enums/vehicle_unit_type.dart';
import '../../../core/combat/extensions/unit_kind_extensions.dart';
import '../../../core/combat/mobile_unit_blueprint.dart';
import '../../../core/combat/movement_style.dart';
import '../../../core/combat/team.dart';
import '../../../core/combat/unit.dart';
import '../../../core/combat/unit_kind.dart';
import '../../../core/combat/unit_objective.dart';
import '../../../core/combat/weapon_type.dart';
import '../../../core/pathfinding/astar.dart';
import '../../ai_director/domain/models/strategy_directive.dart';
import '../../allies/presentation/ally_sprites.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../enemies/presentation/enemy_sprites.dart';
import '../../enemies/presentation/floating_text_component.dart';
import '../../game_core/domain/models/game_status.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../../towers/presentation/tower_component.dart';
import 'bullet_component.dart';
import 'cartoon_poof_component.dart';
import 'dust_puff_component.dart';
import 'explosion_component.dart';
import 'fire_pulse_component.dart';
import 'human_limbs_component.dart';
import 'impact_spark_component.dart';
import 'jet_flare_component.dart';
import 'laser_beam_component.dart';
import 'muzzle_flash_component.dart';
import 'rocket_component.dart';
import 'rotor_component.dart';
import 'smoke_trail_component.dart';
import 'target_highlight_component.dart';
import 'track_mark_component.dart';
import 'vapor_cone_component.dart';
import 'vehicle_tread_component.dart';
import 'vehicle_turret_component.dart';

/// Squared distance within which two same-team, same-domain units push
/// apart a bit while converging on the same path/base instead of
/// overlapping/stacking - see
/// [MobileUnitComponent.applySeparationSteering].
const _separationRadiusSq = 26.0 * 26.0;

/// A single mobile (non-tower) combat unit. Every team and every
/// [UnitObjective] shares this one class - an AI-directed wave invader
/// rushing the player's base and a player-built unit hunting down
/// hostiles are constructed identically, just with a different [team]/
/// [objective]/[blueprint]/[level]. This replaces what used to be two
/// separate class hierarchies (`EnemyComponent`/`AllyUnitComponent` and
/// their many per-kind subclasses) - the handful of things that genuinely
/// differ (where to head next, what happens on arrival/death, whether
/// nearby teammates push apart) are driven by switching on [objective],
/// not by subclassing.
class MobileUnitComponent extends PositionComponent
    with HasGameReference<BoomspireGame>, Unit
    implements Attackable {
  final MobileUnitBlueprint blueprint;
  final Team team;
  final UnitObjective objective;

  /// Fixed world point to head for and hold at - only meaningful when
  /// [objective] is [UnitObjective.captureNode] (a resource node's
  /// position never moves, so a live component reference isn't needed).
  final Vector2? captureTarget;

  /// Upgrade tier (0-based) of the producing building (Training Center/War
  /// Factory), if any - stats scale up with this so investing in the
  /// producer, not a flat spawn, is what makes built units stronger.
  /// Always 0 for units not built by a player structure (e.g. invaders).
  final int level;

  /// A specific world point to spawn at, assigned by the wave director's
  /// entry-point plan (see `WaveDirectorComponent._planSpawnQueue`) - only
  /// meaningful for [UnitObjective.rushBase]. Null falls back to picking a
  /// uniformly random point from [BoomspireGame.terrainMap]'s
  /// `spawnPoints`, same as before this field existed.
  final Vector2? spawnOverride;

  @override
  double health;

  /// True once the player has directly ordered this unit (see
  /// [issueMoveOrder]/[issueAttackOrder]) - from then on [goalPosition]
  /// only ever returns a player-chosen destination (or null, to hold
  /// position) instead of resuming the automatic [objective]-driven goal.
  bool underManualControl = false;

  /// Player-issued "walk here and hold" order - see [issueMoveOrder].
  Vector2? moveOrderTarget;

  /// Player-issued "chase this down and attack it" order - overrides
  /// normal auto-target-acquisition until the target dies/despawns - see
  /// [issueAttackOrder].
  Attackable? forcedTarget;

  List<Vector2> _path = [];
  int _pathIndex = 0;
  double _repathTimer = 0;
  double _attackCooldown = 0;
  Attackable? _engaging;
  Attackable? _huntTarget;
  double _bobPhase = Random().nextDouble() * pi * 2;

  /// Drives the pulsing selection ring/glow in [render] - same idea as
  /// `TowerComponent._idlePhase`, just a separate field so a unit's own
  /// bob/facing animation timing (which varies per [MovementStyle]) never
  /// has to double as the selection-indicator's pulse rate.
  double _idlePhase = Random().nextDouble() * pi * 2;

  /// This unit's actual heading, set by movement/engage code - [_applyBob]
  /// layers its wobble on top of this every frame instead of accumulating
  /// directly into `_visual.angle`, which used to spin the sprite forever
  /// once the unit stopped moving (nothing was left to reset it).
  double _facingAngle = 0;
  double _vaporTimer = 0;
  double _jetFlareTimer = 0;
  double _preExplosionTimer = 0;
  bool _destroyed = false;

  /// Whether this unit actually traveled this frame - gates every
  /// [UnitBodyType]-driven "while moving" visual (engine smoke, tread
  /// scroll, ground track/dust), set fresh in [update] every frame rather
  /// than inferred after the fact.
  bool _wasMoving = false;
  double _engineSmokeTimer = 0;
  double _groundEffectTimer = 0;

  /// Independently-rotating weapon overlay for ground vehicles - null for
  /// infantry, air units, and unarmed vehicles. See [addExtraVisuals].
  VehicleTurretComponent? _turret;

  /// Leg/arm animation overlay for infantry - null for every vehicle. See
  /// [addExtraVisuals].
  HumanLimbsComponent? _limbs;

  /// Scrolling wheel/tread-tick overlay for ground vehicles - null for
  /// infantry and air units. See [addExtraVisuals].
  VehicleTreadComponent? _tread;
  late final PositionComponent _visual;
  late final TargetHighlightComponent _targetHighlight;

  MobileUnitComponent({
    required this.blueprint,
    required this.team,
    required this.objective,
    this.level = 0,
    this.captureTarget,
    this.spawnOverride,
    super.position,
  }) : health = blueprint.maxHealth,
       super(
         size: Vector2.all(blueprint.size),
         anchor: Anchor.center,
         priority: objective == UnitObjective.rushBase ? 10 : 9,
       ) {
    health = effectiveMaxHealth;
  }

  @override
  Set<UnitDomain> get attackDomains => blueprint.attackDomains;

  @override
  bool get destroyed => _destroyed;

  /// Multiplies [MobileUnitBlueprint.attackRange] when scanning for
  /// something to engage - lets the AI director's "clear obstacles"
  /// directive make base-rushers eager to detour toward a tower that
  /// isn't directly on their path yet.
  double get detectionRangeMultiplier =>
      objective == UnitObjective.rushBase &&
          game.enemyFocusHint == FocusHint.clearObstacles
      ? 1.6
      : 1.0;

  @override
  UnitDomain get domain => blueprint.domain;

  /// Current attack damage, after the [level] upgrade multiplier.
  double get effectiveAttackDamage => blueprint.attackDamage * _levelMultiplier;

  /// Current max health, after the [level] upgrade multiplier.
  double get effectiveMaxHealth => blueprint.maxHealth * _levelMultiplier;

  @override
  double get healthRatio => (health / effectiveMaxHealth).clamp(0.0, 1.0);

  /// Whether this unit ever stops to trade fire at all right now - the AI
  /// director can order a "rush the base" wave where nothing engages
  /// defenses no matter how close they get.
  bool get ignoresEngagement =>
      objective == UnitObjective.rushBase &&
      game.enemyFocusHint == FocusHint.rushBase;

  /// Vehicles rushing the base telegraph an impending death with sparking
  /// smoke at low HP - units hunting hostiles just fight to the end.
  bool get showsLowHealthTelegraph => objective == UnitObjective.rushBase;

  double get _levelMultiplier => pow(1.25, level).toDouble();

  /// How far (world units) an attack-ordered unit will look for a new
  /// hostile to press on toward once its current [forcedTarget] dies -
  /// see [_clearForcedTargetAndMaybeContinueHunting]. Scales with the
  /// unit's own attack range so longer-ranged units also scan wider.
  double get _postKillHuntRadius => blueprint.attackRange * 3;

  /// Attaches extra always-on visuals once the model/sprite is loaded -
  /// a spinning rotor for [UnitKind.helicopter], or a [UnitBodyType]-driven
  /// overlay: leg/arm animation for infantry, and a scrolling tread plus
  /// (if armed) an independently-aiming turret for ground vehicles. Air
  /// vehicles other than the helicopter get their jet-flare/vapor-cone
  /// treatment purely in [_flyToward], with no extra child component.
  Future<void> addExtraVisuals(PositionComponent visual) async {
    if (blueprint.kind == UnitKind.helicopter) {
      await visual.add(RotorComponent(position: visual.size / 2));
    }

    final body = blueprint.kind.bodyType;
    if (body is Human) {
      _limbs = HumanLimbsComponent(hullSize: visual.size, accent: team.color);
      await visual.add(_limbs!);
    } else if (body == VehicleUnitType.heavyVehicle ||
        body == VehicleUnitType.lightVehicle) {
      _tread = VehicleTreadComponent(hullSize: visual.size);
      await visual.add(_tread!);
      if (blueprint.attackDamage > 0) {
        _turret = VehicleTurretComponent(
          hullSize: visual.size,
          accent: team.color,
        );
        await visual.add(_turret!);
      }
    }
  }

  /// Blends a raw direction with a short-range separation push away from
  /// nearby teammates, so a crowd converging on the same fixed goal (a
  /// base-rush) flows around itself instead of stacking. Units hunting
  /// varied hostile targets don't need this.
  Vector2 applySeparationSteering(Vector2 dir) {
    if (objective != UnitObjective.rushBase) return dir;
    final separation = Vector2.zero();
    for (final other in game.world.activeUnits) {
      if (identical(other, this)) continue;
      if (other.team.id != team.id) continue;
      if (other.isAirUnit != isAirUnit) continue;
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

  /// Resolves this unit's sprite from whichever side's factory has art for
  /// [blueprint.kind] - prefers the factory matching [team]'s relation to
  /// the player, falling back to the other one for a kind that was only
  /// ever painted for one side (e.g. a player-built Helicopter, or an
  /// invader-only Attack Plane).
  Future<Sprite> buildSprite() {
    final kind = blueprint.kind;
    final alliedWithPlayer =
        team.relationTo(game.playerTeam) == TeamRelation.ally;
    final preferredSupports = alliedWithPlayer
        ? AllySpriteFactory.supports
        : EnemySpriteFactory.supports;
    final preferredSprite = alliedWithPlayer
        ? AllySpriteFactory.spriteFor
        : EnemySpriteFactory.spriteFor;
    final fallbackSprite = alliedWithPlayer
        ? EnemySpriteFactory.spriteFor
        : AllySpriteFactory.spriteFor;
    return preferredSupports(kind)
        ? preferredSprite(kind)
        : fallbackSprite(kind);
  }

  /// Where this unit should head toward right now - a player-issued attack
  /// order beats everything else (chase the target down), then a
  /// player-issued move order; past that, [underManualControl] means "hold
  /// wherever it currently is" rather than resuming the automatic
  /// objective below - the player's base for a base-rush, the opposing
  /// base for a skirmish assault, the nearest live hostile target for a
  /// hunt. Null means "hold position".
  Vector2? goalPosition() {
    if (forcedTarget != null) {
      if (!forcedTarget!.destroyed && forcedTarget!.isMounted) {
        return forcedTarget!.position;
      }
      _clearForcedTargetAndMaybeContinueHunting();
      if (forcedTarget != null) return forcedTarget!.position;
    }
    if (underManualControl) return moveOrderTarget;
    return switch (objective) {
      UnitObjective.rushBase => Vector2(
        game.terrainMap.basePoint.x,
        game.terrainMap.basePoint.y,
      ),
      UnitObjective.assaultBase => game.baseTargetFor(team),
      UnitObjective.huntHostiles => _acquireHuntTarget()?.position,
      UnitObjective.captureNode => captureTarget,
    };
  }

  /// Forces this unit onto a specific starting position before its first
  /// path is computed - base-rushers spawn at a random terrain spawn
  /// point (or [spawnOverride], if the wave director assigned one); null
  /// means "keep whatever position it was constructed with" (hunters are
  /// placed at their producing building).
  Vector2? initialPosition() {
    if (objective != UnitObjective.rushBase) return null;
    final jitter = (Random().nextDouble() - 0.5) * 60;
    if (spawnOverride != null) {
      return Vector2(spawnOverride!.x, spawnOverride!.y + jitter);
    }
    final spawnPoints = game.terrainMap.spawnPoints;
    final sp = spawnPoints[Random().nextInt(spawnPoints.length)];
    return Vector2(sp.x, sp.y + jitter);
  }

  /// Orders this unit to chase down and attack [enemy], overriding whatever
  /// it was doing - see [issueMoveOrder] for the same permanent
  /// [underManualControl] switch.
  void issueAttackOrder(Attackable enemy) {
    underManualControl = true;
    moveOrderTarget = null;
    forcedTarget = enemy;
    // Force an immediate repath instead of waiting on the leftover
    // throttle timer from whatever this unit was doing before - without
    // this, a stale/already-exhausted `_path` from a just-completed order
    // makes `_followPath` think the (brand new) goal was already reached
    // this same tick, silently cancelling the fresh order.
    _repathTimer = 0;
  }

  /// Orders this unit to walk to [point] and hold there once it arrives -
  /// puts it under permanent [underManualControl] (it won't auto-resume
  /// its spawn [objective] afterward), though it still auto-fights
  /// anything that wanders within [MobileUnitBlueprint.attackRange] while
  /// holding (see [_maybeEngage]).
  void issueMoveOrder(Vector2 point) {
    underManualControl = true;
    forcedTarget = null;
    moveOrderTarget = point.clone();
    _repathTimer = 0;
  }

  /// Called by a tower every frame it has this unit locked as its current
  /// target - lights this unit up fully in the tower's accent color for a
  /// brief moment so the player can always tell what's being shot at right
  /// now. Retriggered continuously while targeted, so it stays lit and
  /// only fades once no tower is aiming at it anymore.
  void markTargeted(Color color) => _targetHighlight.trigger(color);

  /// Called right after this unit's own death FX are spawned - a
  /// base-rush unit banks its kill/escape bounty for the player, while a
  /// skirmish assault unit banks its bounty for whichever side destroyed it
  /// (the opposing wallet). A hunter unit banks nothing.
  void onDeath() {
    if (objective == UnitObjective.rushBase) {
      final baseReward =
          blueprint.bounty + (game.gameState.currentWave - 1) * 2;
      final reward = game.gameState.addKillGold(
        baseReward,
        extraBonus: game.goldMineKillGoldBonus,
      );
      game.audioRepository.play(SfxType.goldGain, volume: 0.35);
      game.world.spawn(
        FloatingTextComponent(
          text: '+${reward}g',
          position: position.clone() + Vector2(0, -size.y / 2 - 4),
        ),
      );
      return;
    }
    if (objective != UnitObjective.assaultBase &&
        objective != UnitObjective.captureNode) {
      return;
    }
    if (team.id == game.playerTeam.id) {
      // A player-built unit died in a skirmish - the AI opponent gets the
      // credit (and gold) for the kill.
      game.aiEconomy?.addGold(blueprint.bounty);
      return;
    }
    if (game.aiTeam != null && team.id == game.aiTeam!.id) {
      // An AI-built unit died - the player gets the credit, same escalating
      // streak bonus/Gold Mine bonus as a wave-defense kill.
      final reward = game.gameState.addKillGold(
        blueprint.bounty,
        extraBonus: game.goldMineKillGoldBonus,
      );
      game.audioRepository.play(SfxType.goldGain, volume: 0.35);
      game.world.spawn(
        FloatingTextComponent(
          text: '+${reward}g',
          position: position.clone() + Vector2(0, -size.y / 2 - 4),
        ),
      );
    }
  }

  @override
  Future<void> onLoad() async {
    final spawn = initialPosition();
    if (spawn != null) position = spawn;
    if (!isAirUnit) {
      final goal = goalPosition();
      if (goal != null) _computePath(goal);
    }

    final alliedWithPlayer =
        team.relationTo(game.playerTeam) == TeamRelation.ally;
    _visual = await game.unitRenderRepository.render(
      key: '${alliedWithPlayer ? 'ally' : 'enemy'}_${blueprint.kind.name}',
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
        volume: alliedWithPlayer ? 0.4 : 0.5,
      );
    }

    _targetHighlight = TargetHighlightComponent()
      ..size = size
      ..position = Vector2.zero();
    await add(_targetHighlight);

    if (objective == UnitObjective.huntHostiles) {
      // "Alive" build-in, matching a tower's spawn pop - base-rushers walk
      // on from an off-map spawn point already, so they skip this.
      scale = Vector2.zero();
      add(
        ScaleEffect.to(
          Vector2.all(1),
          EffectController(duration: 0.25, curve: Curves.easeOutBack),
        ),
      );
    }
  }

  /// Called once this unit reaches [goalPosition] with nothing left to
  /// engage - a base-rush escapes past the base and damages the player, a
  /// hunter just holds and waits for a new target next frame.
  void onReachGoal() {
    if (underManualControl) {
      // Arrived at a manual move order - just hold here; a fresh order (or
      // an in-range auto-engage, see [_maybeEngage]) is what moves it next.
      moveOrderTarget = null;
      return;
    }
    if (objective != UnitObjective.rushBase) return;
    game.gameState.damagePlayer(1);
    game.audioRepository.play(SfxType.enemyEscape, volume: 0.5);
    removeSelf();
  }

  /// Everything this unit's weapon might stop and engage instead of
  /// continuing toward [goalPosition] - every mobile unit hostile to
  /// [team], plus any tower/base owned by a side hostile to [team]. In
  /// wave-defense every tower/base is player-owned, so this reduces to the
  /// exact same "towers count only if this unit is hostile to the player"
  /// check it used to be; in a skirmish it also lets AI-owned towers/base
  /// draw player-unit fire and vice versa.
  Iterable<Attackable> opposingTargets() {
    final targets = <Attackable>[
      ...game.world.unitsHostileTo(team),
      ...game.world.activeTowers.where(
        (t) => team.relationTo(t.owner) == TeamRelation.enemy,
      ),
    ];
    final base = game.enemyHomeBaseFor(team);
    if (base != null) targets.add(base);
    return targets;
  }

  /// Removes this unit from the world's active roster.
  void removeSelf() => game.world.removeUnit(this);

  @override
  void render(Canvas canvas) {
    // Selection indicator - mirrors `TowerComponent.render`'s selection
    // ring so tapping a unit reads the same way as tapping a tower: a
    // pulsing glow around the unit itself plus (when it actually has a
    // weapon) a range ring showing how far it can engage from here. Its
    // current focus target is separately tinted via [markTargeted] in
    // [_maybeEngage].
    if (game.selectedUnit.value == this) {
      final center = Offset(size.x / 2, size.y / 2);
      final accent = team.color;
      final pulse = 0.5 + 0.5 * sin(_idlePhase * 1.6);

      if (blueprint.attackRange > 0) {
        canvas.drawCircle(
          center,
          blueprint.attackRange,
          Paint()..color = accent.withValues(alpha: 0.04 + pulse * 0.04),
        );
        canvas.drawCircle(
          center,
          blueprint.attackRange,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5 + pulse
            ..color = accent.withValues(alpha: 0.35 + pulse * 0.3),
        );
      }

      canvas.drawCircle(
        center,
        size.x * 0.62 + pulse * 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 + pulse
          ..color = accent.withValues(alpha: 0.55 + pulse * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

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

  /// Lower is better - the "closest wins" default (used by hunters and
  /// most AI-director focus hints). A base-rush unit can instead chase
  /// the weakest tower, or strongly prefer towers/structures over other
  /// mobile units when directed to clear obstacles.
  double scoreFor(Attackable candidate, double distance) {
    if (objective != UnitObjective.rushBase) return distance;
    final hint = game.enemyFocusHint;
    var score = hint == FocusHint.weakestTower
        ? candidate.healthRatio
        : distance;
    final preferStructures =
        blueprint.prefersStructures || hint == FocusHint.clearObstacles;
    if (preferStructures) {
      score *= candidate is TowerComponent ? 0.4 : 2.2;
    }
    return score;
  }

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
    _idlePhase += dt * 2.2;

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
      _wasMoving = false;
      _applyBob(dt);
      _updateVisualExtras(dt);
      return;
    }

    final goal = goalPosition();
    _wasMoving = goal != null;
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
    _updateVisualExtras(dt);
  }

  /// Keeps chasing the same hostile it already committed to instead of
  /// re-picking "the nearest one" fresh every frame - without this, two
  /// similarly-distant hostiles made the unit flip back and forth between
  /// them (visible as aimless wandering instead of closing in to attack).
  /// Only switches when the current target is gone or a genuinely closer
  /// target shows up.
  Attackable? _acquireHuntTarget() {
    final current = _huntTarget;
    if (current != null &&
        !current.isRemoving &&
        !current.destroyed &&
        canAttack(current.domain)) {
      final nearest = _nearestOpposing();
      if (nearest == null || identical(nearest, current)) return current;
      final currentDist = current.position.distanceTo(position);
      final nearestDist = nearest.position.distanceTo(position);
      if (nearestDist < currentDist * 0.75) _huntTarget = nearest;
      return _huntTarget;
    }
    return _huntTarget = _nearestOpposing();
  }

  void _applyBob(double dt) {
    _bobPhase += dt * (blueprint.movementStyle == MovementStyle.roll ? 6 : 10);
    switch (blueprint.movementStyle) {
      case MovementStyle.walk:
        _visual.position = size / 2 + Vector2(0, sin(_bobPhase) * 1.5);
      case MovementStyle.roll:
        _visual.position = size / 2;
        _visual.angle = _facingAngle + sin(_bobPhase) * 0.05;
      case MovementStyle.hover:
        _visual.position = size / 2 + Vector2(0, sin(_bobPhase) * 2.5);
      case MovementStyle.swoop:
        _visual.position = size / 2;
        _visual.angle = _facingAngle + sin(_bobPhase * 0.5) * 0.08;
      case MovementStyle.sail:
        _visual.position = size / 2 + Vector2(0, sin(_bobPhase) * 2);
        _visual.angle = _facingAngle + sin(_bobPhase * 0.5) * 0.06;
    }
  }

  /// Called whenever [forcedTarget] turns out to be stale (destroyed or
  /// unmounted). If this unit was under a player attack order (not just a
  /// plain move order), immediately looks for another nearby hostile
  /// within [_postKillHuntRadius] and keeps fighting - "after destroying
  /// the enemy, move to the next enemy in its radius". Finding none, the
  /// unit simply holds position and waits for the player's next order,
  /// same as finishing a plain move order.
  void _clearForcedTargetAndMaybeContinueHunting() {
    forcedTarget = null;
    if (!underManualControl) return;
    forcedTarget = _nearestOpposingWithin(_postKillHuntRadius);
    if (forcedTarget != null) _repathTimer = 0;
  }

  void _computePath(Vector2 goal) {
    final grid = game.terrainMap.grid;
    final startCell = grid.worldToCell(position);
    final goalCell = grid.worldToCell(goal);
    final cells = AStarPathFinder.findPath(grid, startCell, goalCell);
    final points = (cells ?? [goalCell]).map(grid.cellCenter).toList();
    // Drop the waypoint for the cell we're already standing in - keeping it
    // made the unit visibly snap/backtrack to that exact center on every
    // repath instead of continuing straight on toward the next waypoint,
    // which was the main source of the "wandering" look.
    if (points.length > 1 &&
        points.first.distanceTo(position) < grid.cellSize * 0.5) {
      points.removeAt(0);
    }
    // The last waypoint always snaps to the goal cell's *center*, not the
    // literal requested point - fine for a long path (a cell-width of
    // slop at the very end is invisible), but when start and goal share a
    // single cell (a short move order well under one cell in length) that
    // center can already be within one frame's movement of where the unit
    // is standing right now, so it "arrives" and holds instantly without
    // ever actually walking toward the point the player tapped. Snapping
    // the final waypoint to the exact goal fixes that without changing
    // anything about longer, multi-cell paths.
    if (points.isNotEmpty) points[points.length - 1] = goal.clone();
    _path = points;
    _pathIndex = 0;
    _repathTimer = 0.5 + Random().nextDouble() * 0.3;
  }

  void _die() {
    _destroyed = true;
    final alliedWithPlayer =
        team.relationTo(game.playerTeam) == TeamRelation.ally;
    if (blueprint.isVehicle) {
      game.audioRepository.play(
        SfxType.vehicleExplosion,
        volume: alliedWithPlayer ? 0.5 : 0.6,
      );
      game.world.spawn(
        ExplosionComponent(
          position: position.clone(),
          radius: size.x * (alliedWithPlayer ? 0.85 : 0.9),
        ),
      );
    } else {
      game.audioRepository.play(
        SfxType.soldierPop,
        volume: alliedWithPlayer ? 0.4 : 0.5,
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

  /// Fires this unit's whole volley (`blueprint.projectileCount` shots) at
  /// once - a single shot for most units, but a fanned-out multi-round
  /// barrage (e.g. the Artillery Barrage's 3 rockets) when that's more
  /// than 1. The volley's total damage is split evenly across the shots
  /// so changing the round count reshapes the attack instead of buffing
  /// it.
  void _fireAt(Attackable target, Vector2 toTarget) {
    final dir = toTarget.normalized();
    final side = Vector2(-dir.y, dir.x);
    final volleySize = blueprint.projectileCount;
    final perShotDamage = effectiveAttackDamage / volleySize;
    final accent = team.color;

    _limbs?.pulseFire();
    game.shakeCamera(power: effectiveAttackDamage, origin: position.clone());
    // Recoil kick - punchier the bigger the volley, so a 3-round barrage
    // visibly reads as heavier than a single shot.
    _visual.add(
      ScaleEffect.by(
        Vector2.all(volleySize > 1 ? 0.82 : 0.92),
        EffectController(
          duration: 0.05,
          reverseDuration: 0.12,
          curve: Curves.easeOut,
        ),
      ),
    );

    for (var i = 0; i < volleySize; i++) {
      // Fan simultaneous rounds out side-by-side instead of stacking them
      // on the exact same line, so a multi-round volley reads as a spread
      // barrage rather than one shot repeated.
      final spread = volleySize == 1 ? 0.0 : (i - (volleySize - 1) / 2) * 9.0;
      final spawnPos = position + dir * (size.x / 2) + side * spread;
      _spawnProjectile(spawnPos, target, perShotDamage, accent);
      game.world.spawn(MuzzleFlashComponent(position: spawnPos));
    }

    _playFireSfx();
    game.world.spawn(
      FirePulseComponent(
        position: position.clone(),
        color: accent,
        maxRadius: FirePulseComponent.radiusFor(
          range: blueprint.attackRange,
          damage: effectiveAttackDamage,
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
    _facingAngle = atan2(dir.y, dir.x) + pi / 2;

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

    if (blueprint.kind.bodyType == VehicleUnitType.plane) {
      _jetFlareTimer -= dt;
      if (_jetFlareTimer <= 0) {
        _jetFlareTimer = 0.05;
        game.world.spawn(
          JetFlareComponent(
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
      _facingAngle = atan2(dir.y, dir.x) + pi / 2;
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
    if (forcedTarget != null &&
        (forcedTarget!.destroyed || !forcedTarget!.isMounted)) {
      _clearForcedTargetAndMaybeContinueHunting();
    }

    Attackable? target;
    if (forcedTarget != null) {
      // A player-issued attack order only fires once actually in range -
      // otherwise `goalPosition` (which also reads `forcedTarget`) is what
      // walks this unit toward it first.
      final maxDist = blueprint.attackRange * detectionRangeMultiplier;
      final inRange = forcedTarget!.position.distanceTo(position) <= maxDist;
      target = (inRange && canAttack(forcedTarget!.domain))
          ? forcedTarget
          : null;
    } else {
      _engaging ??= _findTargetInRange();
      target = _engaging;
    }
    if (target == null) return false;

    // Only tint the target when this unit is the one selected/tapped -
    // otherwise every unit on the map would highlight its target at once.
    if (game.selectedUnit.value == this) {
      final t = target;
      if (t is MobileUnitComponent) {
        t.markTargeted(team.color);
      } else if (t is TowerComponent) {
        t.markTargeted(team.color);
      }
    }

    final toTarget = target.position - position;
    _facingAngle = atan2(toTarget.y, toTarget.x) + pi / 2;

    // A zero-length tick (e.g. the single `update(0)` frame used to mount
    // a just-spawned unit) must never resolve a shot - otherwise simply
    // spawning a new hostile near an idle, already-engaged unit can
    // insta-kill it before any real simulation time or player order ever
    // happens.
    if (dt <= 0) return true;

    _attackCooldown -= dt;
    if (_attackCooldown <= 0) {
      _attackCooldown = blueprint.attackInterval;
      _fireAt(target, toTarget);
    }
    return true;
  }

  Attackable? _nearestOpposing() {
    Attackable? best;
    var bestDist = double.infinity;
    for (final candidate in opposingTargets()) {
      if (candidate.isRemoving) continue;
      if (!canAttack(candidate.domain)) continue;
      final d = candidate.position.distanceTo(position);
      if (d < bestDist) {
        best = candidate;
        bestDist = d;
      }
    }
    return best;
  }

  /// Closest live, attackable hostile within [radius] - used to auto-chain
  /// an attack order onto the next nearby enemy once the current one dies.
  Attackable? _nearestOpposingWithin(double radius) {
    Attackable? best;
    var bestDist = double.infinity;
    for (final candidate in opposingTargets()) {
      if (candidate.isRemoving || candidate.destroyed) continue;
      if (!canAttack(candidate.domain)) continue;
      final d = candidate.position.distanceTo(position);
      if (d > radius || d >= bestDist) continue;
      best = candidate;
      bestDist = d;
    }
    return best;
  }

  void _playFireSfx() {
    final hostileToPlayer =
        team.relationTo(game.playerTeam) == TeamRelation.enemy;
    switch (blueprint.weaponType) {
      case WeaponType.bullet:
        game.audioRepository.play(
          hostileToPlayer ? SfxType.enemyShot : SfxType.machineGunShot,
          volume: 0.3,
        );
      case WeaponType.cannon:
        game.audioRepository.play(SfxType.cannonShot, volume: 0.5);
      case WeaponType.rocket:
        game.audioRepository.play(SfxType.rocketLaunch, volume: 0.5);
      case WeaponType.laser:
        game.audioRepository.play(SfxType.laserShot, volume: 0.4);
    }
  }

  /// Spawns a single projectile/effect of [blueprint.weaponType] for one
  /// shot of a volley - called once per round by [_fireAt].
  void _spawnProjectile(
    Vector2 spawnPos,
    Attackable target,
    double damage,
    Color accent,
  ) {
    final hostileToPlayer =
        team.relationTo(game.playerTeam) == TeamRelation.enemy;
    switch (blueprint.weaponType) {
      case WeaponType.bullet:
        game.world.spawn(
          BulletComponent(
            start: spawnPos,
            target: target,
            damage: damage,
            fromEnemy: hostileToPlayer,
          ),
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
            firedBy: team,
            attackDomains: blueprint.attackDomains,
          ),
        );
      case WeaponType.rocket:
        game.world.spawn(
          RocketComponent(
            start: spawnPos,
            target: target,
            damage: damage,
            splashRadius: 60,
            bodyColor: const Color(0xFFB0BEC5),
            tipColor: accent,
            firedBy: team,
            attackDomains: blueprint.attackDomains,
          ),
        );
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
    }
  }

  /// Shortest-path angle interpolation, shared by [_turret]'s aim - same
  /// idea as `TowerComponent._turnToward`.
  double _turnToward(double current, double target, double maxDelta) {
    var diff = (target - current) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    if (diff < -pi) diff += 2 * pi;
    if (diff.abs() <= maxDelta) return target;
    return current + maxDelta * diff.sign;
  }

  /// Per-frame upkeep for the [UnitBodyType]-specific visuals attached in
  /// [addExtraVisuals]: continuous engine smoke + turret aim for vehicles,
  /// ground track/dust + tread scroll for wheeled/tracked vehicles, and leg
  /// animation for infantry - layered on top of [_applyBob] rather than
  /// replacing it, so the existing per-[MovementStyle] wobble is untouched.
  void _updateVisualExtras(double dt) {
    _limbs?.setPhase(_bobPhase);

    final body = blueprint.kind.bodyType;
    if (body is Human) return;

    if (_turret != null) {
      final aimTarget = _engaging ?? forcedTarget;
      final aimAngle = (aimTarget != null && !aimTarget.destroyed)
          ? atan2(
                  aimTarget.position.y - position.y,
                  aimTarget.position.x - position.x,
                ) +
                pi / 2
          : _facingAngle;
      _turret!.angle = _turnToward(_turret!.angle, aimAngle, dt * 8);
    }

    _tread?.moving = _wasMoving;
    if (!_wasMoving) return;

    _engineSmokeTimer -= dt;
    if (_engineSmokeTimer <= 0) {
      _engineSmokeTimer = 0.5;
      game.world.spawn(
        SmokeTrailComponent(position: position.clone() + Vector2(0, -6)),
      );
    }

    if (isAirUnit) return;
    _groundEffectTimer -= dt;
    if (_groundEffectTimer <= 0) {
      if (body == VehicleUnitType.heavyVehicle) {
        _groundEffectTimer = 0.3;
        game.world.spawn(
          TrackMarkComponent(position: position.clone(), angle: _facingAngle),
        );
      } else if (body == VehicleUnitType.lightVehicle) {
        _groundEffectTimer = 0.18;
        game.world.spawn(
          DustPuffComponent(
            position: position.clone() + Vector2(0, size.y * 0.3),
          ),
        );
      }
    }
  }
}
