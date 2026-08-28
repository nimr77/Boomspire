import '../../../../core/combat/unit_kind.dart';
import '../../../towers/presentation/tower_component.dart';
import '../../../towers/presentation/training_center_component.dart';
import '../../../towers/presentation/war_factory_component.dart';
import '../../domain/models/production_option.dart';
import '../boomspire_game.dart';

/// Computes what a selected Training Center/War Factory's produce-unit row
/// should show - the repository-consuming logic behind
/// `GameCoreEntityPanelWidget`'s build menu, kept out of the widget per
/// the presentation state-layer rule. Stateless (no per-instance data), so
/// it's registered app-wide in `service_locator.dart`.
class GameCoreProductionState {
  List<ProductionOption> optionsFor(BoomspireGame game, TowerComponent tower) {
    final ready = _isReady(tower);
    final cooldownRemaining = _cooldownRemaining(tower);
    final costFor = _costForFn(tower);
    final gold = game.gameState.gold;
    return [
      for (final kind in _producibleKinds(game, tower))
        ProductionOption(
          kind: kind,
          ready: ready,
          cooldownRemaining: cooldownRemaining,
          cost: costFor(kind),
          affordable: ready && gold >= costFor(kind),
        ),
    ];
  }

  void produce(TowerComponent tower, UnitKind kind) {
    if (tower is TrainingCenterComponent) {
      tower.produceUnit(kind);
    } else if (tower is WarFactoryComponent) {
      tower.produceUnit(kind);
    }
  }

  double _cooldownRemaining(TowerComponent tower) => tower is TrainingCenterComponent
      ? tower.cooldownRemaining
      : (tower as WarFactoryComponent).cooldownRemaining;

  int Function(UnitKind) _costForFn(TowerComponent tower) =>
      tower is TrainingCenterComponent ? tower.costFor : (tower as WarFactoryComponent).costFor;

  bool _isReady(TowerComponent tower) =>
      tower is TrainingCenterComponent ? tower.canProduce : (tower as WarFactoryComponent).canProduce;

  Iterable<UnitKind> _producibleKinds(BoomspireGame game, TowerComponent tower) {
    if (tower is TrainingCenterComponent) return TrainingCenterComponent.producibleKinds;
    return game.unitRepository
        .kindsFor(game.playerTeam)
        .where((kind) => !TrainingCenterComponent.producibleKinds.contains(kind));
  }
}
