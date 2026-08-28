import 'package:flame/components.dart' show Vector2;

import '../../../core/combat/attackable.dart';
import '../../../core/combat/unit_kind.dart';
import '../../../core/combat/unit_objective.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../game_core/domain/models/game_config.dart';
import '../../game_core/domain/models/game_scene.dart';
import 'tower_component.dart';

/// Non-combat structure: it never fires (zero range/damage). Instead, the
/// player mans it via the build menu shown when it's selected on the
/// battlefield (see `GameCoreEntityPanelWidget`), spending gold to roll out any
/// buildable unit of their choosing that heads out to hunt down the
/// nearest hostile on its own (see
/// `MobileUnitComponent`/`UnitObjective.huntHostiles`) - or, on a
/// [GameMode.skirmish] map, marches to assault the AI's base instead.
class WarFactoryComponent extends TowerComponent {
  /// Seconds left before another vehicle/aircraft can be queued - starts
  /// ready.
  double cooldownRemaining = 0;

  WarFactoryComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  bool get canProduce => !destroyed && cooldownRemaining <= 0;

  int costFor(UnitKind kind) =>
      game.unitRepository.blueprintFor(owner, kind).cost;

  @override
  void fire(Attackable target) {}

  /// Spends gold to roll out an Ally unit of the given [kind] - called
  /// from the action panel's build menu. [objective]/[captureTarget] let a
  /// caller (currently only `AiSkirmishControllerComponent`) send the unit
  /// on a resource-node capture run instead of its usual errand; omit both
  /// for the normal hunt/assault behavior. Returns whether it actually
  /// happened.
  bool produceUnit(
    UnitKind kind, {
    UnitObjective? objective,
    Vector2? captureTarget,
  }) {
    if (!canProduce) return false;
    if (!game.canProduceUnit(kind, owner: owner)) return false;
    final blueprint = game.unitRepository.blueprintFor(owner, kind);
    if (!game.spendGoldFor(owner, blueprint.cost)) return false;
    cooldownRemaining = GameConfig.warFactoryProductionCooldown;
    game.world.spawnUnit(
      MobileUnitComponent(
        blueprint: blueprint,
        position: position.clone(),
        team: owner,
        objective:
            objective ??
            (game.scene.mode == GameMode.skirmish
                ? UnitObjective.assaultBase
                : UnitObjective.huntHostiles),
        captureTarget: captureTarget,
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
