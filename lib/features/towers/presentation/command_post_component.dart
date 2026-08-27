import '../../combat/presentation/mobile_unit_component.dart';
import 'tower_component.dart';

/// Support structure: never fires, but each one standing raises the max
/// number of Artillery Bunkers that can be built (see
/// `BoomspireGame.buildLimitFor`). If a Command Post is destroyed or sold,
/// any Bunker that only exists thanks to its support is torn down too (see
/// `BoomspireGame.enforceSupportedTowerLimits`).
class CommandPostComponent extends TowerComponent {
  CommandPostComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  @override
  void fire(MobileUnitComponent target) {}
}
