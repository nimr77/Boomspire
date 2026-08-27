import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../combat/presentation/rocket_component.dart';
import 'tower_component.dart';

/// Long-range, air-only missile site - only buildable once the Tech Lab and
/// Command Post have both been built (see `BoomspireGame.canBuildTower`) and
/// capped at 2 standing at once. Reaches flyers from far away but is very
/// fragile up close, so it relies on other towers to screen it.
class SamTowerComponent extends TowerComponent {
  SamTowerComponent({
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
        attackDomains: blueprint.attackDomains,
      ),
    );
    game.audioRepository.play(SfxType.rocketLaunch, volume: 0.65);
  }
}
