import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;

import '../../../core/combat/attackable.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../enemies/presentation/enemy_component.dart';

/// A unit produced by the Training Center or War Factory: unlike a tower,
/// it isn't tied to a grid cell - it walks/flies out and hunts down the
/// nearest enemy on the map, engaging it in a direct firefight. Movement/
/// firing/death FX are all inherited from `MobileUnitComponent` - this
/// class only supplies the ally-specific policy (seek the nearest enemy,
/// scale stats with the producing building's upgrade level).
abstract class AllyUnitComponent extends MobileUnitComponent {
  /// Upgrade tier (0-based) of the Training Center/War Factory that
  /// mustered this unit - its stats scale with that building's level so
  /// player investment in the producer, not a flat spawn, is what makes
  /// ally units stronger.
  final int level;

  EnemyComponent? _chaseTarget;

  AllyUnitComponent({
    required super.blueprint,
    required super.position,
    required super.team,
    this.level = 0,
  }) {
    health = effectiveMaxHealth;
  }

  @override
  double get effectiveAttackDamage => blueprint.attackDamage * _levelMultiplier;

  @override
  double get effectiveMaxHealth => blueprint.maxHealth * _levelMultiplier;

  double get _levelMultiplier => pow(1.25, level).toDouble();

  @override
  Vector2? goalPosition() => _chaseEnemy()?.position;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
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
  Iterable<Attackable> opposingTargets() => game.world.activeEnemies;

  @override
  void removeSelf() => game.world.removeAlly(this);

  /// Keeps chasing the same enemy it already committed to instead of
  /// re-picking "the nearest one" fresh every frame - without this, two
  /// similarly-distant enemies made the unit flip back and forth between
  /// them (visible as aimless wandering instead of closing in to attack).
  /// Only switches when the current target is gone or a genuinely closer
  /// target shows up.
  EnemyComponent? _chaseEnemy() {
    final current = _chaseTarget;
    if (current != null &&
        !current.isRemoving &&
        !current.destroyed &&
        canAttack(current.domain)) {
      final nearest = _nearestEnemy();
      if (nearest == null || identical(nearest, current)) return current;
      final currentDist = current.position.distanceTo(position);
      final nearestDist = nearest.position.distanceTo(position);
      if (nearestDist < currentDist * 0.75) _chaseTarget = nearest;
      return _chaseTarget;
    }
    return _chaseTarget = _nearestEnemy();
  }

  EnemyComponent? _nearestEnemy() {
    EnemyComponent? best;
    var bestDist = double.infinity;
    for (final enemy in game.world.activeEnemies) {
      if (enemy.isRemoving) continue;
      if (!canAttack(enemy.domain)) continue;
      final d = enemy.position.distanceTo(position);
      if (d < bestDist) {
        best = enemy;
        bestDist = d;
      }
    }
    return best;
  }
}
