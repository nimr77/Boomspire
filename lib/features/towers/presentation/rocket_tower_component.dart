import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../combat/presentation/rocket_component.dart';
import 'tower_component.dart';

class RocketTowerComponent extends TowerComponent {
  RocketTowerComponent({
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
        firedBy: game.playerTeam,
        attackDomains: blueprint.attackDomains,
      ),
    );
    game.audioRepository.play(SfxType.rocketLaunch, volume: 0.6);
  }
}
