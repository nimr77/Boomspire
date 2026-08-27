import '../../../core/combat/attackable.dart';
import 'tower_component.dart';

/// Non-combat structure: it never fires (zero range/damage), it just needs
/// to be built once to unlock the Laser Lance in the build menu (see
/// `BoomspireGame.hasTechLabFor`).
class TechLabComponent extends TowerComponent {
  TechLabComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  @override
  void fire(Attackable target) {}
}
