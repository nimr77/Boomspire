import '../../../core/combat/attackable.dart';
import 'tower_component.dart';

/// Non-combat structure: it never fires (zero range/damage), it just needs
/// to be built once to unlock the Tech Lab in the build menu (see
/// `BoomspireGame.hasPowerPlantFor`).
class PowerPlantComponent extends TowerComponent {
  PowerPlantComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  @override
  void fire(Attackable target) {}
}
