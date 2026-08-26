import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;

import '../../../core/combat/targetable.dart';
import '../../../core/rendering/model_loader.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/explosion_component.dart';
import '../../combat/presentation/fire_pulse_component.dart';
import '../../combat/presentation/impact_spark_component.dart';
import '../../combat/presentation/smoke_trail_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import '../../game_core/presentation/circuit_defense_game.dart';
import '../domain/models/tower_blueprint.dart';
import 'tower_sprites.dart';

/// Maximum number of times a tower can be upgraded - each tier boosts
/// damage/range/HP and brightens its accent ring.
const int kMaxTowerUpgradeLevel = 3;

/// Base tower: sits on a build cell, scans for the nearest valid enemy in
/// range, swivels its turret to face it, and fires on cooldown. Also tracks
/// structural HP - enemies can shoot towers down, and the player can repair,
/// upgrade, or sell them for gold.
abstract class TowerComponent extends PositionComponent
    with HasGameReference<CircuitDefenseGame>
    implements Targetable {
  final TowerBlueprint blueprint;

  double hp;
  double maxHp;
  int col = 0;
  int row = 0;
  double _cooldown = 0;
  int upgradeLevel = 0;

  /// Total gold ever invested in this tower (build cost + every upgrade) -
  /// used to compute a fair sell refund.
  int _investedGold;

  bool _destroyed = false;
  double _idlePhase = Random().nextDouble() * pi * 2;
  double _lowHpSmokeTimer = 0;
  late final PositionComponent turret;
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

  bool get destroyed => _destroyed;

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

  bool get canUpgrade => upgradeLevel < kMaxTowerUpgradeLevel;

  /// Gold cost for the next upgrade tier - rises steeply so upgrades stay a
  /// meaningful late-game gold sink.
  int get upgradeCost =>
      (blueprint.cost * 0.75 * pow(1.6, upgradeLevel + 1)).ceil();

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

    // "Alive" build-in: pop in from nothing instead of just appearing.
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.28, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
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

  /// Spends gold (already deducted by the caller) to raise this tower's
  /// damage/range/max-HP by one tier and brighten its visuals.
  void upgrade() {
    if (_destroyed || !canUpgrade) return;
    _investedGold += upgradeCost;
    upgradeLevel++;
    final missing = maxHp - hp;
    maxHp *= 1.25;
    hp = maxHp - missing;
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

  /// Multiplier applied to [blueprint.damage]/[blueprint.range] based on
  /// [upgradeLevel] - subclasses' `fire()` should read effective stats
  /// through [effectiveDamage]/[effectiveRange] instead of the raw blueprint.
  double get _upgradeMultiplier => pow(1.25, upgradeLevel).toDouble();

  double get effectiveDamage => blueprint.damage * _upgradeMultiplier;

  double get effectiveRange => blueprint.range * (1 + upgradeLevel * 0.08);

  @override
  void takeDamage(double amount) {
    if (_destroyed) return;
    hp = (hp - amount).clamp(0, maxHp);
    if (hp <= 0) _destroy();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_destroyed) return;
    _idlePhase += dt * 2.2;
    _cooldown -= dt;

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

    final target = _acquireTarget();
    if (target == null) return;

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
  }

  EnemyComponent? _acquireTarget() {
    EnemyComponent? closest;
    var closestDist = effectiveRange;
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
    if (game.selectedTower.value == this) game.selectedTower.value = null;
    game.audioRepository.play(SfxType.towerDestroyed, volume: 0.7);
    game.terrainMap.grid.setTowerOccupied(col, row, false);
    game.shakeCamera(power: 30, origin: position.clone());
    game.world.spawn(
      ExplosionComponent(position: position.clone(), radius: size.x * 0.9),
    );
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
