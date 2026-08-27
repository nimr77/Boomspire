import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/attackable.dart';
import '../../../core/combat/team.dart';
import '../../ai_director/domain/models/strategy_directive.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../towers/presentation/tower_component.dart';
import 'floating_text_component.dart';

/// Enemies within this squared distance of each other push apart a bit
/// (see [EnemyComponent.applySeparationSteering]) instead of overlapping/
/// stacking while converging on the same path or base.
const _separationRadiusSq = 26.0 * 26.0;

/// Base enemy: ground types path-find across the whole terrain (routing
/// around mountains and towers), flyers ignore obstacles and beeline for the
/// base. Any enemy with an attack stat will stop to shoot a tower/ally unit
/// blocking its way. Resolves death/escape (gold reward or player damage)
/// once it reaches the base or is destroyed. Movement/firing/death FX are
/// all inherited from `MobileUnitComponent` - this class only supplies the
/// enemy-specific policy (rush the base, prioritize towers, award gold).
abstract class EnemyComponent extends MobileUnitComponent {
  late final _TargetHighlightComponent _targetHighlight;

  EnemyComponent({required super.blueprint}) : super(team: Team.enemy);

  @override
  double get detectionRangeMultiplier =>
      game.enemyFocusHint == FocusHint.clearObstacles ? 1.6 : 1.0;

  @override
  bool get ignoresEngagement => game.enemyFocusHint == FocusHint.rushBase;

  @override
  bool get showsLowHealthTelegraph => true;

  /// Blends the raw path/beeline direction with a short-range separation
  /// push away from nearby enemies of the same domain (ground vs air don't
  /// need to avoid each other) - without this, enemies converging on the
  /// same waypoint/base pile up directly on top of one another instead of
  /// flowing around each other like a real crowd would.
  @override
  Vector2 applySeparationSteering(Vector2 dir) {
    final separation = Vector2.zero();
    for (final other in game.world.activeEnemies) {
      if (identical(other, this)) continue;
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

  @override
  Vector2? goalPosition() =>
      Vector2(game.terrainMap.basePoint.x, game.terrainMap.basePoint.y);

  @override
  Vector2? initialPosition() {
    final spawnPoints = game.terrainMap.spawnPoints;
    final sp = spawnPoints[Random().nextInt(spawnPoints.length)];
    final jitter = (Random().nextDouble() - 0.5) * 60;
    return Vector2(sp.x, sp.y + jitter);
  }

  /// Called by a tower every frame it has this enemy locked as its current
  /// target - lights this enemy up fully in the tower's accent color for a
  /// brief moment so the player can always tell what's being shot at right
  /// now. Retriggered continuously while targeted, so it stays lit and only
  /// fades once no tower is aiming at it anymore.
  void markTargeted(Color color) => _targetHighlight.trigger(color);

  @override
  void onDeath() {
    final baseReward = blueprint.bounty + (game.gameState.currentWave - 1) * 2;
    final reward = game.gameState.addKillGold(baseReward);
    game.audioRepository.play(SfxType.goldGain, volume: 0.35);
    game.world.spawn(
      FloatingTextComponent(
        text: '+${reward}g',
        position: position.clone() + Vector2(0, -size.y / 2 - 4),
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _targetHighlight = _TargetHighlightComponent()
      ..size = size
      ..position = Vector2.zero();
    await add(_targetHighlight);
  }

  @override
  void onReachGoal() {
    game.gameState.damagePlayer(1);
    game.audioRepository.play(SfxType.enemyEscape, volume: 0.5);
    removeSelf();
  }

  @override
  Iterable<Attackable> opposingTargets() => [
    ...game.world.activeTowers,
    ...game.world.activeAllies,
  ];

  @override
  void removeSelf() => game.world.removeEnemy(this);

  /// "Score" is what's minimized: distance for nearest-target targeting,
  /// remaining HP ratio when the director wants weak targets focused down
  /// first. A "clear obstacles" directive - or an artillery-style unit that
  /// always prefers structures - additionally biases hard toward towers
  /// over ally units, so this unit detours to shell defenses instead of
  /// just trading fire with whatever's closest.
  @override
  double scoreFor(Attackable candidate, double distance) {
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
}

/// Drawn as the last child of an [EnemyComponent] so it renders on top of
/// the sprite - fills the enemy's own silhouette (via [BlendMode.srcATop])
/// with the targeting tower's accent color, so "who's currently being shot
/// at" reads instantly from across the battlefield.
class _TargetHighlightComponent extends PositionComponent {
  static const _fadeDuration = 0.35;

  Color _color = const Color(0x00000000);
  double _timer = 0;

  @override
  void render(Canvas canvas) {
    if (_timer <= 0) return;
    final ratio = _timer / _fadeDuration;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x * 0.55,
      Paint()
        ..color = _color.withValues(alpha: 0.7 * ratio)
        ..blendMode = BlendMode.srcATop,
    );
  }

  void trigger(Color color) {
    _color = color;
    _timer = _fadeDuration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_timer > 0) _timer = (_timer - dt).clamp(0, _fadeDuration);
  }
}
