import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/targetable.dart';
import '../../../core/combat/team.dart';
import '../../../core/combat/unit.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../game_core/presentation/boomspire_game.dart';
import 'explosion_component.dart';
import 'fire_component.dart';
import 'smoke_trail_component.dart';

/// Slower homing rocket/shell that leaves a smoke trail and detonates into a
/// splash-damage explosion on arrival. Shared by the rocket battery and the
/// siege cannon (with different colors/impact damage).
class RocketComponent extends PositionComponent
    with HasGameReference<BoomspireGame> {
  static const _speed = 340.0;

  final Targetable target;
  final double damage;
  final double splashRadius;
  final Color bodyColor;
  final Color tipColor;

  /// Which domains splash damage can hit - mirrors the firing unit's own
  /// [Unit.attackDomains] so, e.g., a ground-only Rocket Battery splash
  /// never clips a helicopter/plane just passing overhead.
  final Set<UnitDomain> attackDomains;

  /// The [Team] that fired this shell - used to find every hostile thing
  /// (mobile units, towers, and the home base alike) to splash-damage, see
  /// [_detonate].
  final Team firedBy;
  double _trailTimer = 0;
  RocketComponent({
    required Vector2 start,
    required this.target,
    required this.damage,
    required this.splashRadius,
    required this.firedBy,
    this.bodyColor = const Color(0xFFB0BEC5),
    this.tipColor = const Color(0xFFFF7043),
    this.attackDomains = const {
      UnitDomain.ground,
      UnitDomain.air,
      UnitDomain.sea,
    },
  }) : super(position: start, size: Vector2(15, 5), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(2),
      ),
      Paint()..color = bodyColor,
    );
    canvas.drawCircle(
      Offset(size.x - 2, size.y / 2),
      2.6,
      Paint()..color = tipColor,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _trailTimer -= dt;
    if (_trailTimer <= 0) {
      _trailTimer = 0.03;
      game.world.spawn(SmokeTrailComponent(position: position.clone()));
    }

    final aimPoint = (target.isMounted && !target.isRemoving)
        ? target.position
        : position;
    final toTarget = aimPoint - position;
    final dist = toTarget.length;
    angle = atan2(toTarget.y, toTarget.x);

    final step = _speed * dt;
    if (dist <= step || target.isRemoving || !target.isMounted) {
      _detonate();
      return;
    }
    position += toTarget.normalized() * step;
  }

  void _detonate() {
    game.audioRepository.play(SfxType.explosion, volume: 0.8);
    game.shakeCamera(
      power: damage + splashRadius * 0.5,
      origin: position.clone(),
    );
    game.world.spawn(
      ExplosionComponent(position: position.clone(), radius: splashRadius),
    );
    // A rocket/shell impact leaves a lingering fire behind, on top of the
    // instantaneous explosion flash above.
    game.world.spawn(
      FireComponent(position: position.clone(), radius: splashRadius * 0.3),
    );
    // A splash hits every hostile thing in range at once - a mobile unit
    // caught in a shell meant for a tower still gets hurt, and vice versa -
    // instead of the old exclusive "either units or towers/base" split that
    // let a whole category go untouched depending on who fired.
    for (final unit in List.of(game.world.unitsHostileTo(firedBy))) {
      if (!attackDomains.contains(unit.domain)) continue;
      if (unit.position.distanceTo(position) <= splashRadius) {
        unit.takeDamage(damage);
      }
    }
    for (final tower in List.of(game.world.activeTowers)) {
      if (firedBy.relationTo(tower.owner) != TeamRelation.enemy) continue;
      if (tower.position.distanceTo(position) <= splashRadius) {
        tower.takeDamage(damage);
      }
    }
    final base = game.enemyHomeBaseFor(firedBy);
    if (base != null && base.position.distanceTo(position) <= splashRadius) {
      base.takeDamage(damage);
    }
    removeFromParent();
  }
}
