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
  /// Seconds left before another soldier can be queued - starts ready.
  double cooldownRemaining = 0;

  TrainingCenterComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  bool get canProduce => !destroyed && cooldownRemaining <= 0;

  int get soldierCost =>
      game.unitRepository.blueprintFor(owner, UnitKind.soldier).cost;

  @override
  void fire(MobileUnitComponent target) {}

  /// Spends gold to muster a fresh Ally Soldier - called from the action
  /// panel's build menu. Returns whether it actually happened.
  bool produceSoldier() {
    if (!canProduce) return false;
    if (!game.spendGoldFor(owner, soldierCost)) return false;
    cooldownRemaining = GameConfig.trainingCenterProductionCooldown;
    game.world.spawnUnit(
      MobileUnitComponent(
        blueprint: game.unitRepository.blueprintFor(owner, UnitKind.soldier),
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
