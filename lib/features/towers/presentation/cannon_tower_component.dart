import 'dart:ui';

import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../combat/presentation/rocket_component.dart';
import 'tower_component.dart';

/// Heavy siege artillery: slow, expensive, big splash damage - ground only.
class CannonTowerComponent extends TowerComponent {
  CannonTowerComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  @override
  void fire(MobileUnitComponent target) {
    final dir = (target.position - position).normalized();
    final spawnPos = position + dir * (size.x / 2);
    game.world.spawn(
      RocketComponent(
        start: spawnPos,
        target: target,
        damage: effectiveDamage,
        splashRadius: blueprint.splashRadius,
        firedBy: owner,
        bodyColor: const Color(0xFF616161),
        tipColor: const Color(0xFFFFC107),
        attackDomains: blueprint.attackDomains,
      ),
    );
    game.audioRepository.play(SfxType.cannonShot, volume: 0.8);
  }
}
