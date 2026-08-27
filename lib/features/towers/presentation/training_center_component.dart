import '../../../core/combat/unit_kind.dart';
import '../../allies/presentation/ally_soldier_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import '../../game_core/domain/models/game_config.dart';
import 'tower_component.dart';

/// Non-combat structure: it never fires (zero range/damage). Instead, the
/// player mans it via the build menu shown when it's selected on the
/// battlefield (see `TowerActionPanel`), spending gold to muster a fresh
/// Ally Soldier that walks out to hunt down the nearest enemy on its own
/// (see `AllyUnitComponent`).
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
      game.unitRepository.blueprintFor(game.playerTeam, UnitKind.soldier).cost;

  @override
  void fire(EnemyComponent target) {}

  /// Spends gold to muster a fresh Ally Soldier - called from the action
  /// panel's build menu. Returns whether it actually happened.
  bool produceSoldier() {
    if (!canProduce) return false;
    if (!game.gameState.spendGold(soldierCost)) return false;
    cooldownRemaining = GameConfig.trainingCenterProductionCooldown;
    game.world.spawnAlly(
      AllySoldierComponent(
        blueprint: game.unitRepository.blueprintFor(
          game.playerTeam,
          UnitKind.soldier,
        ),
        position: position.clone(),
        team: game.playerTeam,
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
