import '../../../core/combat/attackable.dart';
import '../../../core/combat/unit_kind.dart';
import '../../../core/combat/unit_objective.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../game_core/domain/models/game_config.dart';
import '../../game_core/domain/models/game_scene.dart';
import 'tower_component.dart';

/// Non-combat structure: it never fires (zero range/damage). Instead, the
/// player mans it via the build menu shown when it's selected on the
/// battlefield (see `TowerActionPanel`), spending gold to muster a fresh
/// Ally Soldier that walks out to hunt down the nearest hostile on its own
/// (see `MobileUnitComponent`/`UnitObjective.huntHostiles`) - or, on a
/// [GameMode.skirmish] map, marches to assault the AI's base instead.
class TrainingCenterComponent extends TowerComponent {
  /// Every [UnitKind] this building can muster - a plain Soldier plus the
  /// two specialist infantry kinds, all buildable side-by-side from the
  /// action panel's build row.
  static const producibleKinds = [
    UnitKind.soldier,
    UnitKind.antiTankSoldier,
    UnitKind.antiAirSoldier,
  ];

  /// Seconds left before another soldier can be queued - starts ready.
  double cooldownRemaining = 0;

  TrainingCenterComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  bool get canProduce => !destroyed && cooldownRemaining <= 0;

  int get soldierCost => costFor(UnitKind.soldier);

  int costFor(UnitKind kind) => game.unitRepository.blueprintFor(owner, kind).cost;

  @override
  void fire(Attackable target) {}

  /// Spends gold to muster a fresh Ally Soldier - called from the action
  /// panel's build menu. Returns whether it actually happened.
  bool produceSoldier() => produceUnit(UnitKind.soldier);

  /// Spends gold to muster an Ally unit of the given [kind] (must be one of
  /// [producibleKinds]) - called from the action panel's build menu.
  /// Returns whether it actually happened.
  bool produceUnit(UnitKind kind) {
    if (!canProduce) return false;
    final blueprint = game.unitRepository.blueprintFor(owner, kind);
    if (!game.spendGoldFor(owner, blueprint.cost)) return false;
    cooldownRemaining = GameConfig.trainingCenterProductionCooldown;
    game.world.spawnUnit(
      MobileUnitComponent(
        blueprint: blueprint,
        position: position.clone(),
        team: owner,
        objective: game.scene.mode == GameMode.skirmish
            ? UnitObjective.assaultBase
            : UnitObjective.huntHostiles,
        level: upgradeLevel,
      ),
    );
    return true;
  }


  @override
  void update(double dt) {
    super.update(dt);
    if (cooldownRemaining > 0) {
      cooldownRemaining = (cooldownRemaining - dt).clamp(0, double.infinity);
    }
  }
}
