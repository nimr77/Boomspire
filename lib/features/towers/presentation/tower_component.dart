import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;

import '../../../core/combat/attackable.dart';
import '../../../core/combat/team.dart';
import '../../../core/combat/unit.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/explosion_component.dart';
import '../../combat/presentation/fire_pulse_component.dart';
import '../../combat/presentation/impact_spark_component.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../combat/presentation/rocket_component.dart';
import '../../combat/presentation/smoke_trail_component.dart';
import '../../combat/presentation/target_highlight_component.dart';
import '../../enemies/presentation/floating_text_component.dart';
import '../../game_core/domain/models/game_config.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../domain/models/unit_blueprint.dart';
import 'tower_sprites.dart';

/// Gold cost to attach a point-defense module that shoots down incoming
/// enemy rockets/shells before they land - it goes down with the tower if
/// the tower itself is ever destroyed.
const int kAntiRocketCost = 70;

/// Maximum number of times a tower can be upgraded - each tier boosts
/// damage/range/HP and brightens its accent ring.
const int kMaxTowerUpgradeLevel = 3;

/// Seconds between anti-rocket intercepts - without this it could shoot
/// down every rocket in range every single frame.
const double _antiRocketFireRate = 0.6;

/// How close an enemy rocket/shell must get before an anti-rocket-equipped
/// tower intercepts it - kept short-range so it reads as point-blank
/// point-defense rather than sniping rockets out of the sky far away.
const double _antiRocketRange = 50;

/// Base tower: sits on a build cell, scans for the nearest valid enemy in
/// range, swivels its turret to face it, and fires on cooldown. Also tracks
/// structural HP - enemies can shoot towers down, and the player can repair,
/// upgrade, or sell them for gold.
abstract class TowerComponent extends PositionComponent
    with HasGameReference<BoomspireGame>, Unit
    implements Attackable {
  /// Seconds between shield charges regenerating once regen kicks in.
  static const double _shieldRechargeInterval = 6.0;

  /// How many of a team's towers are allowed to pile onto the same still-
  /// healthy target before the rest look elsewhere - see
  /// [_isGoodFocusFireTarget].
  static const int _maxSharedTargeters = 3;

  /// A target at or below this health fraction is "about to be destroyed" -
  /// once some other tower already on it can finish it within
  /// [_finishingBlowShots], every other tower should peel off onto a
  /// different target instead of contesting/wasting shots on the kill.
  static const double _nearDeathHealthRatio = 0.3;

  static const int _finishingBlowShots = 5;

  final UnitBlueprint blueprint;
  double hp;
  double maxHp;
  int col = 0;

  int row = 0;

  double _cooldown = 0;

  int upgradeLevel = 0;

  /// Current shield charges remaining - each charge fully blocks one
  /// incoming hit (regardless of its damage) instead of chipping away at
  /// [hp], then depletes; recharges on its own once the tower stops taking
  /// hits for a bit.
  int shield = 0;

  double _shieldRegenDelay = 0;

  double _shieldRegenProgress = 0;

  /// Extra shield charges granted by the comeback mechanic (see
  /// [_grantComebackBonus]), on top of the normal per-tier [shieldMax] -
  /// folded into that cap so a bonus shield is never invisible/un-regenerating.
  int _bonusShieldCharges = 0;

  /// Point-defense module - when true, this tower shoots down any enemy
  /// rocket/shell that gets within [_antiRocketRange] of it.
  bool antiRocket = false;

  /// Who this tower belongs to - always the human player in wave-defense.
  /// In a [GameMode.skirmish] match, [BoomspireGame.createTower]/the AI
  /// controller set this to [Team.aiOpponent] for AI-built towers so
  /// targeting/splash/anti-rocket all key off the actual owner instead of
  /// unconditionally assuming the player. Set post-construction (not a
  /// constructor param) so no tower subclass needs its signature changed.
  Team owner = Team.defaultPlayer;

  double _antiRocketCooldown = 0;

  /// Total gold ever invested in this tower (build cost + every upgrade) -
  /// used to compute a fair sell refund.
  int _investedGold;
  bool _destroyed = false;
  double _idlePhase = Random().nextDouble() * pi * 2;

  double _lowHpSmokeTimer = 0;

  late final PositionComponent turret;
  late final TargetHighlightComponent _targetHighlight;

  /// Player-issued "always shoot this specific enemy, even if a closer or
  /// less-contested one is available" order - see
  /// `BoomspireGame.handleArenaTap`. Cleared automatically once the target
  /// dies/despawns. A stationary tower can't chase, so while this is set but
  /// the target is out of range/domain, the tower simply holds fire instead
  /// of falling back to auto-acquiring something else. Can be a mobile unit
  /// or an enemy tower/building - see [towersHostileTo] in `GameWorld`.
  Attackable? forcedTarget;

  /// Whatever this tower actually fired at (or tried to) last frame -
  /// `null` if nothing was in range. Snapshotted once per frame into
  /// `GameWorld.targeterCounts` so every tower's [_acquireTarget] can see
  /// how contested a candidate already is without each one re-scanning
  /// every other tower itself.
  Attackable? currentTarget;

  TowerComponent({
    required Vector2 position,
    required double cellSize,
    required this.blueprint,
  }) : hp = blueprint.maxHp,
       maxHp = blueprint.maxHp,
       _investedGold = blueprint.cost,
       super(
         position: position,
         size: Vector2.all(cellSize),
         anchor: Anchor.center,
         priority: 5,
       );

  @override
  Set<UnitDomain> get attackDomains => blueprint.attackDomains;

  /// Upgrading is gated behind repair: a damaged tower must be brought back
  /// to full HP first, THEN it becomes eligible for the next tier.
  bool get canUpgrade => upgradeLevel < kMaxTowerUpgradeLevel && hp >= maxHp;

  @override
  bool get destroyed => _destroyed;

  @override
  UnitDomain get domain => blueprint.domain;

  double get effectiveDamage => blueprint.damage * _upgradeMultiplier;

  double get effectiveRange => blueprint.range * (1 + upgradeLevel * 0.08);

  @override
  double get health => hp;

  @override
  double get healthRatio => (hp / maxHp).clamp(0.0, 1.0);

  /// Gold cost to fully repair from current HP - 0 once at full health.
  int get repairCost {
    final missing = maxHp - hp;
    if (missing <= 0) return 0;
    return (missing / maxHp * blueprint.cost * 0.6).ceil();
  }

  /// Gold refunded if sold right now - a fraction of everything invested,
  /// scaled down further the more damaged the tower currently is.
  int get sellValue {
    final hpRatio = (hp / maxHp).clamp(0.0, 1.0);
    return (_investedGold * 0.5 * (0.6 + hpRatio * 0.4)).round();
  }

  /// Shield capacity for the current tier, in whole hits blocked - 0 until
  /// the first upgrade, then one charge per upgrade tier (so a fully
  /// upgraded tower blocks up to [kMaxTowerUpgradeLevel] shots), plus any
  /// [_bonusShieldCharges] from the comeback mechanic.
  int get shieldMax => upgradeLevel + _bonusShieldCharges;

  /// Gold cost for the next upgrade tier - rises steeply so upgrades stay a
  /// meaningful late-game gold sink, and rises further as the run goes on
  /// (see `GameConfig.upgradeCostWaveScaling`) since kills also pay out more
  /// gold as the streak bonus builds up (see
  /// `GameStateRepository.addKillGold`).
  int get upgradeCost {
    final waveScaling =
        1 + game.gameState.currentWave * GameConfig.upgradeCostWaveScaling;
    return (blueprint.cost * 0.75 * pow(1.6, upgradeLevel + 1) * waveScaling)
        .ceil();
  }

  /// Multiplier applied to [blueprint.damage]/[blueprint.range] based on
  /// [upgradeLevel] - subclasses' `fire()` should read effective stats
  /// through [effectiveDamage]/[effectiveRange] instead of the raw blueprint.
  double get _upgradeMultiplier => pow(1.25, upgradeLevel).toDouble();

  /// Forcibly destroys this tower outside of normal combat - used when the
  /// support building that allowed it to be built (see
  /// `BoomspireGame.enforceSupportedTowerLimits`) is itself destroyed/sold.
  void destroyBySupportLoss() => _destroy();

  /// Spawns the appropriate projectile/effect toward [target] - a mobile
  /// unit or an enemy tower/building.
  void fire(Attackable target);

  /// Forces this tower to keep shooting [enemy] over whatever it would
  /// otherwise auto-acquire - see [forcedTarget]. The order itself is
  /// accepted regardless of current range (matches
  /// `MobileUnitComponent.issueAttackOrder`'s forgiveness); it only
  /// actually fires once [enemy] is within [effectiveRange].
  void issueAttackOrder(Attackable enemy) => forcedTarget = enemy;

  /// Lets whoever's currently targeting this tower (a [MobileUnitComponent])
  /// tint it with their own color while the player has that attacker
  /// selected - mirrors [MobileUnitComponent.markTargeted].
  void markTargeted(Color color) => _targetHighlight.trigger(color);

  @override
  Future<void> onLoad() async {
    final cell = game.terrainMap.grid.worldToCell(position);
    col = cell.x;
    row = cell.y;

    final baseSprite = await game.unitRenderRepository.render(
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

    turret =
        PositionComponent(
          anchor: Anchor.center,
          position: size / 2,
          scale: Vector2.all(1 + upgradeLevel * 0.12),
        )..add(
          SpriteComponent(
            sprite: await TowerSpriteFactory.turret(blueprint.type),
            size: size * 0.75,
            anchor: Anchor.center,
          ),
        );
    await add(turret);

    _targetHighlight = TargetHighlightComponent()
      ..size = size
      ..position = Vector2.zero();
    await add(_targetHighlight);

    // "Alive" build-in: pop in from nothing instead of just appearing.
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.28, curve: Curves.easeOutBack),
      ),
    );

    game.selectedTower.addListener(_onSelectionChanged);
  }

  @override
  void onRemove() {
    game.selectedTower.removeListener(_onSelectionChanged);
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    // Selection indicator - a slowly-spinning, breathing 8-point star ring
    // in the tower's own accent color, drawn under everything else.
    if (game.selectedTower.value == this) {
      final accent = TowerSpriteFactory.accentColor(blueprint.type);
      final center = Offset(size.x / 2, size.y / 2);

      // Pulsing range ring - tapping a built tower reveals its coverage,
      // same as the pre-build ghost preview.
      if (effectiveRange > 0) {
        final rangePulse = 0.5 + 0.5 * sin(_idlePhase * 1.6);
        canvas.drawCircle(
          center,
          effectiveRange,
          Paint()..color = accent.withValues(alpha: 0.04 + rangePulse * 0.04),
        );
        canvas.drawCircle(
          center,
          effectiveRange,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5 + rangePulse
            ..color = accent.withValues(alpha: 0.35 + rangePulse * 0.3),
        );
      }

      // Dead-zone ring - a hatched red disc marking the minimum engagement
      // radius for long-range-only weapons (e.g. the Rocket Silo), so it
      // reads clearly as "can't fire in here" rather than just less range.
      if (blueprint.minRange > 0) {
        canvas.drawCircle(
          center,
          blueprint.minRange,
          Paint()..color = const Color(0xFFE53935).withValues(alpha: 0.18),
        );
        canvas.drawCircle(
          center,
          blueprint.minRange,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = const Color(0xFFE53935).withValues(alpha: 0.6),
        );
      }

      final pulse = 0.5 + 0.5 * sin(_idlePhase * 1.6);
      final outerR = size.x * 0.85 + pulse * 3;
      final innerR = outerR * 0.55;
      final rotation = _idlePhase * 0.25;
      final star = Path();
      for (var i = 0; i < 16; i++) {
        final r = i.isEven ? outerR : innerR;
        final a = rotation + i * pi / 8;
        final pt = center.translate(cos(a) * r, sin(a) * r);
        if (i == 0) {
          star.moveTo(pt.dx, pt.dy);
        } else {
          star.lineTo(pt.dx, pt.dy);
        }
      }
      star.close();
      canvas.drawPath(
        star,
        Paint()
          ..color = accent.withValues(alpha: 0.14 + pulse * 0.06)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        star,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = accent.withValues(alpha: 0.75 + pulse * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    // Subtle idle "breathing" glow ring so an undamaged tower still reads
    // as active/crewed hardware rather than a static prop.
    final breath = 0.5 + 0.5 * sin(_idlePhase);
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x * 0.42 + breath * 1.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = TowerSpriteFactory.accentColor(blueprint.type)
            .withValues(alpha: 0.12 + breath * 0.1),
    );

    // Tier rank chevrons - a quick, unmistakable "this tower got upgraded"
    // read, stacked above the HP bar, one per upgrade level.
    for (var i = 0; i < upgradeLevel; i++) {
      final cy = -18.0 - i * 6;
      final chevron = Path()
        ..moveTo(size.x / 2 - 6, cy + 4)
        ..lineTo(size.x / 2, cy)
        ..lineTo(size.x / 2 + 6, cy + 4);
      canvas.drawPath(
        chevron,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFD54A),
      );
    }

    // Shield bubble - only present once the first upgrade grants one,
    // opacity/thickness scale with how much charge is currently banked.
    if (shieldMax > 0) {
      final shieldRatio = (shield / shieldMax).clamp(0.0, 1.0).toDouble();
      if (shieldRatio > 0) {
        canvas.drawCircle(
          Offset(size.x / 2, size.y / 2),
          size.x * 0.56,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 + shieldRatio * 1.5
            ..color = const Color(0xFF40C4FF)
                .withValues(alpha: 0.25 + shieldRatio * 0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }

    if (hp >= maxHp) return;
    final ratio = (hp / maxHp).clamp(0.0, 1.0);
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
    hp = (hp + amount).clamp(0, maxHp);
    game.world.spawn(
      ImpactSparkComponent(
        position: position.clone(),
        color: const Color(0xFF69F0AE),
      ),
    );
    add(
      SequenceEffect([
        ScaleEffect.to(Vector2.all(1.12), EffectController(duration: 0.09)),
        ScaleEffect.to(Vector2.all(1), EffectController(duration: 0.16)),
      ]),
    );
  }

  @override
  void takeDamage(double amount) {
    if (_destroyed) return;
    _shieldRegenDelay = 3.0;
    if (shield > 0) {
      shield--;
      return;
    }
    hp = (hp - amount).clamp(0, maxHp);
    if (hp <= 0) _destroy();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_destroyed) return;
    _idlePhase += dt * 2.2;
    _cooldown -= dt;
    _antiRocketCooldown -= dt;

    if (shieldMax > 0 && shield < shieldMax) {
      if (_shieldRegenDelay > 0) {
        _shieldRegenDelay -= dt;
      } else {
        _shieldRegenProgress += dt;
        if (_shieldRegenProgress >= _shieldRechargeInterval) {
          _shieldRegenProgress -= _shieldRechargeInterval;
          shield++;
        }
      }
    } else {
      _shieldRegenProgress = 0;
    }

    final hpRatio = hp / maxHp;
    if (hpRatio < 0.35) {
      _lowHpSmokeTimer -= dt;
      if (_lowHpSmokeTimer <= 0) {
        _lowHpSmokeTimer = 0.5 + Random().nextDouble() * 0.4;
        game.world.spawn(
          SmokeTrailComponent(
            position: position.clone() + Vector2(0, -size.y * 0.3),
          ),
        );
      }
    }

    final target = _resolveTarget();
    currentTarget = target;
    if (target == null) {
      _scanAntiRocket();
      return;
    }
    // Only tint the target when this tower is the one selected/tapped -
    // otherwise every tower on the map would highlight its target at once.
    // Uses this tower's own accent color (not the team color) so the
    // highlight visually matches the tower doing the shooting.
    if (game.selectedTower.value == this) {
      final accent = TowerSpriteFactory.accentColor(blueprint.type);
      if (target is MobileUnitComponent) {
        target.markTargeted(accent);
      } else if (target is TowerComponent) {
        target.markTargeted(accent);
      }
    }

    final toTarget = target.position - position;
    final desiredAngle = atan2(toTarget.y, toTarget.x) + pi / 2;
    turret.angle = _turnToward(turret.angle, desiredAngle, dt * 8);

    if (_cooldown <= 0) {
      fire(target);
      game.shakeCamera(power: effectiveDamage, origin: position.clone());
      game.world.spawn(
        FirePulseComponent(
          position: position.clone(),
          color: TowerSpriteFactory.accentColor(blueprint.type),
          maxRadius: FirePulseComponent.radiusFor(
            range: effectiveRange,
            damage: effectiveDamage,
          ),
        ),
      );
      _cooldown = blueprint.fireRate;
    }
    _scanAntiRocket();
  }

  /// Spends gold (already deducted by the caller) to raise this tower's
  /// damage/range/max-HP by one tier and brighten its visuals.
  void upgrade() {
    if (_destroyed || !canUpgrade) return;
    _investedGold += upgradeCost;
    upgradeLevel++;
    final missing = maxHp - hp;
    maxHp *= 1.25;
    hp = maxHp - missing;
    shield = shieldMax;
    turret.scale = Vector2.all(1 + upgradeLevel * 0.12);
    game.audioRepository.play(SfxType.towerUpgrade, volume: 0.7);
    game.world.spawn(
      ImpactSparkComponent(
        position: position.clone(),
        color: const Color(0xFFFFD54A),
      ),
    );
    add(
      SequenceEffect([
        ScaleEffect.to(Vector2.all(1.22), EffectController(duration: 0.12)),
        ScaleEffect.to(Vector2.all(1), EffectController(duration: 0.22)),
      ]),
    );
  }

  Attackable? _acquireTarget() {
    // Stay locked onto whatever this tower is already engaged with as long
    // as it's still a valid shot - without this, every tower re-picks
    // "closest + least-contested" completely fresh every single frame,
    // which (a) reads as distracting target-flicker even when nothing
    // meaningful changed, and (b) would make the shared-targeter cap below
    // actively harmful: several towers that all locked onto the same
    // target on the same frame would all see themselves counted in that
    // same frame's stale snapshot and could all bail at once. The cap only
    // ever gates a tower picking a *new* target, never staying on one it's
    // already committed to - the one exception is peeling off a near-dead
    // target once a faster-killing tower has that kill in hand (see
    // [_hasFasterFinisherAssigned]).
    final sticky = currentTarget;
    if (sticky != null &&
        !sticky.destroyed &&
        sticky.isMounted &&
        canAttack(sticky.domain)) {
      final d = sticky.position.distanceTo(position);
      if (d >= blueprint.minRange &&
          d <= effectiveRange &&
          !_hasFasterFinisherAssigned(sticky)) {
        return sticky;
      }
    }

    // Prefer whatever the last completed background focus-fire scan (see
    // `GameWorld._refreshTargetAssignments`, `computeTargetAssignments`)
    // already worked out for this tower - the O(towers x enemies) scan
    // behind it runs on a separate isolate via `compute()` instead of every
    // tower redoing it inline on the main isolate every frame. Still
    // double-checked here since the result can be up to
    // `GameWorld._targetComputeInterval` stale.
    final suggested = game.world.suggestedTargetFor(this);
    if (suggested != null && canAttack(suggested.domain)) {
      final d = suggested.position.distanceTo(position);
      if (d >= blueprint.minRange && d <= effectiveRange) return suggested;
    }

    // Fallback: no background suggestion yet (just spawned, or the last
    // scan hasn't landed) - run the same scoring synchronously so the
    // tower is never left waiting on an isolate round-trip to react.
    // Enemy towers/buildings are scored exactly like mobile units - just
    // another stationary ground target, gated the same way by
    // [Unit.canAttack]/[blueprint.minRange].
    Attackable? closest;
    var closestDist = effectiveRange;
    Attackable? bestSmart;
    var bestSmartDist = effectiveRange;

    final candidates = <Attackable>[
      ...game.world.unitsHostileTo(owner),
      ...game.world.towersHostileTo(owner),
    ];
    for (final enemy in candidates) {
      if (!canAttack(enemy.domain)) continue;
      final d = enemy.position.distanceTo(position);
      if (d < blueprint.minRange) continue;
      if (d <= closestDist) {
        closest = enemy;
        closestDist = d;
      }
      if (d <= bestSmartDist && _isGoodFocusFireTarget(enemy)) {
        bestSmart = enemy;
        bestSmartDist = d;
      }
    }
    // Prefer a target that isn't already being dog-piled/isn't about to be
    // finished off by someone else - but never leave the tower idle just
    // because every candidate in range failed that bar.
    return bestSmart ?? closest;
  }

  void _destroy() {
    _destroyed = true;
    forcedTarget = null;
    currentTarget = null;
    if (game.selectedTower.value == this) game.selectedTower.value = null;
    game.audioRepository.play(SfxType.towerDestroyed, volume: 0.7);
    game.terrainMap.grid.setTowerOccupied(col, row, false);
    game.shakeCamera(power: 30, origin: position.clone());
    game.world.spawn(
      ExplosionComponent(position: position.clone(), radius: size.x * 0.9),
    );
    _reinforceNearestSurvivor();
    game.world.removeTower(this);
  }

  /// Applies the actual comeback bonus (see [_reinforceNearestSurvivor])
  /// plus a floating-text callout so the payoff reads clearly on screen.
  void _grantComebackBonus() {
    if (_destroyed) return;
    if (canUpgrade) {
      upgrade();
      game.world.spawn(
        FloatingTextComponent(
          text: 'Reinforced!',
          position: position.clone() + Vector2(0, -size.y / 2 - 4),
        ),
      );
    } else {
      _bonusShieldCharges = max(_bonusShieldCharges, 2);
      shield = shieldMax;
      game.audioRepository.play(SfxType.towerRepair, volume: 0.6);
      game.world.spawn(
        ImpactSparkComponent(
          position: position.clone(),
          color: const Color(0xFF40C4FF),
        ),
      );
      game.world.spawn(
        FloatingTextComponent(
          text: 'Shield Boost!',
          position: position.clone() + Vector2(0, -size.y / 2 - 4),
        ),
      );
    }
  }

  /// True once [target] is nearly dead and some *other* tower of ours
  /// already assigned to it can finish it off faster than this one could -
  /// used both to keep a fresh pick away from a kill someone else already
  /// has in hand, and to make an already-assigned tower peel off and let
  /// that faster one solo the kill instead of every tower on it wasting
  /// shots finishing off the last sliver of health together. Ties (equal
  /// shots-to-kill) favor staying put over both towers abandoning it.
  bool _hasFasterFinisherAssigned(Attackable target) {
    if (target.healthRatio > _nearDeathHealthRatio) return false;
    final myShots = (target.health / effectiveDamage).ceil();
    for (final other in game.world.activeTowers) {
      if (identical(other, this) || other.owner.id != owner.id) continue;
      if (!identical(other.currentTarget, target)) continue;
      final otherShots = (target.health / other.effectiveDamage).ceil();
      if (otherShots < _finishingBlowShots && otherShots < myShots) {
        return true;
      }
    }
    return false;
  }

  /// Whether [enemy] is a sensible *new* pick for this tower to target this
  /// frame, given how contested it already is - computed from
  /// `GameWorld.targeterCounts`, a single per-frame O(towers) snapshot
  /// (see `GameWorld._refreshTargeterCounts`) rather than each tower
  /// re-scanning every other tower itself, so this stays cheap even with a
  /// full battlefield of towers. Only gates freshly acquiring a target -
  /// see [_acquireTarget]'s stickiness for why an already-assigned tower
  /// doesn't re-run this cap check every frame.
  bool _isGoodFocusFireTarget(Attackable enemy) {
    if (enemy.healthRatio <= _nearDeathHealthRatio) {
      // Doomed - if another tower already on it can finish it off quickly,
      // don't contest that kill; go find something else instead.
      return !_hasFasterFinisherAssigned(enemy);
    }
    final targeters = game.world.targeterCounts[enemy] ?? 0;
    return targeters < _maxSharedTargeters;
  }

  /// One-shot "snap" pop whenever this tower becomes the selected one, on
  /// top of the continuously-animated star ring drawn in [render].
  void _onSelectionChanged() {
    if (game.selectedTower.value != this || _destroyed) return;
    add(
      SequenceEffect([
        ScaleEffect.to(Vector2.all(1.15), EffectController(duration: 0.08)),
        ScaleEffect.to(Vector2.all(1), EffectController(duration: 0.14)),
      ]),
    );
  }

  /// Comeback mechanic: losing a tower to enemy fire automatically routes a
  /// bonus into the nearest surviving tower - a free upgrade tier if it can
  /// still take one, otherwise an emergency shield charge.
  void _reinforceNearestSurvivor() {
    TowerComponent? nearest;
    var nearestDist = double.infinity;
    for (final other in game.world.activeTowers) {
      if (other == this || other.destroyed) continue;
      final d = other.position.distanceTo(position);
      if (d < nearestDist) {
        nearest = other;
        nearestDist = d;
      }
    }
    nearest?._grantComebackBonus();
  }

  /// Picks whatever this tower should actually shoot at this frame: a
  /// player-issued [forcedTarget] always wins (and locks the tower onto it
  /// exclusively - it holds fire rather than auto-retargeting while the
  /// forced target is merely out of range), otherwise falls back to the
  /// normal focus-fire-aware auto-acquisition.
  Attackable? _resolveTarget() {
    final forced = forcedTarget;
    if (forced != null) {
      if (forced.destroyed || !forced.isMounted) {
        forcedTarget = null;
      } else {
        final d = forced.position.distanceTo(position);
        final inRange = d <= effectiveRange && d >= blueprint.minRange;
        return (inRange && canAttack(forced.domain)) ? forced : null;
      }
    }
    return _acquireTarget();
  }

  /// If this tower has the anti-rocket module, shoots down the first enemy
  /// rocket/shell it finds within [_antiRocketRange] before it can land.
  void _scanAntiRocket() {
    if (!antiRocket || _antiRocketCooldown > 0) return;
    for (final rocket in game.world.children.query<RocketComponent>()) {
      if (rocket.firedBy.relationTo(owner) != TeamRelation.enemy ||
          rocket.isRemoving) {
        continue;
      }
      if (rocket.position.distanceTo(position) > _antiRocketRange) continue;
      rocket.removeFromParent();
      game.world.spawn(
        ImpactSparkComponent(
          position: rocket.position.clone(),
          color: const Color(0xFF40C4FF),
        ),
      );
      game.audioRepository.play(SfxType.antiAirShot, volume: 0.4);
      _antiRocketCooldown = _antiRocketFireRate;
      break;
    }
  }

  double _turnToward(double current, double target, double maxDelta) {
    var diff = (target - current) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    if (diff < -pi) diff += 2 * pi;
    if (diff.abs() <= maxDelta) return target;
    return current + maxDelta * diff.sign;
  }
}
