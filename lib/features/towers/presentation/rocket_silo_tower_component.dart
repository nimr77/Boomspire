import '../../../core/combat/attackable.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../combat/presentation/rocket_component.dart';
import 'tower_component.dart';

/// Damage multiplier applied against big/armored targets (vehicles and
/// naval units) - this is the tower's whole purpose: long range and a
/// heavy payload built to reach and crack open big units other towers
/// struggle to bring down.
const double _kBigTargetDamageMultiplier = 1.6;

class RocketSiloTowerComponent extends TowerComponent {
  RocketSiloTowerComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  @override
  void fire(Attackable target) {
    // Towers/buildings are never a vehicle/sea unit - only a mobile unit's
    // blueprint can trigger the big-target bonus.
    final isBigTarget =
        target is MobileUnitComponent &&
        (target.blueprint.isVehicle || target.blueprint.isSeaUnit);
    final dir = (target.position - position).normalized();
    final spawnPos = position + dir * (size.x / 2);
    game.world.spawn(
      RocketComponent(
        start: spawnPos,
        target: target,
        damage: isBigTarget
            ? effectiveDamage * _kBigTargetDamageMultiplier
            : effectiveDamage,
        splashRadius: blueprint.splashRadius,
        firedBy: owner,
        attackDomains: blueprint.attackDomains,
      ),
    );
    game.audioRepository.play(SfxType.rocketLaunch, volume: 0.7);
  }
}
