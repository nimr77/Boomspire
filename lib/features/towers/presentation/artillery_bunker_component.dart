import 'dart:ui';

import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/rocket_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import 'tower_component.dart';

/// Heavy, armored artillery - only buildable while at least one Command
/// Post is standing, and only up to as many as are currently supported
/// (see `BoomspireGame.buildLimitFor`).
class ArtilleryBunkerComponent extends TowerComponent {
  ArtilleryBunkerComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  @override
  void fire(EnemyComponent target) {
    final dir = (target.position - position).normalized();
    final spawnPos = position + dir * (size.x / 2);
    game.world.spawn(
      RocketComponent(
        start: spawnPos,
        target: target,
        damage: effectiveDamage,
        splashRadius: blueprint.splashRadius,
        bodyColor: const Color(0xFF6d5a4e),
        tipColor: const Color(0xFF8D6E63),
        canHitAir: blueprint.canTargetAir,
        canHitGround: blueprint.canTargetGround,
      ),
    );
    game.audioRepository.play(SfxType.cannonShot, volume: 0.75);
  }
}
