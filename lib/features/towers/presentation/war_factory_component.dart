import '../../allies/domain/models/ally_unit_type.dart';
import '../../allies/presentation/ally_aircraft_component.dart';
import '../../allies/presentation/ally_light_vehicle_component.dart';
import '../../allies/presentation/ally_tank_component.dart';
import '../../allies/presentation/ally_unit_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import '../../game_core/domain/models/game_config.dart';
import 'tower_component.dart';

/// Non-combat structure: it never fires (zero range/damage). Instead, the
/// player mans it via the build menu shown when it's selected on the
/// battlefield (see `TowerActionPanel`), spending gold to roll out an Ally
/// tank, light vehicle or aircraft of their choosing that heads out to hunt
/// down the nearest enemy on its own (see `AllyUnitComponent`).
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

  int costFor(AllyUnitType type) =>
      game.allyUnitRepository.blueprintFor(type).cost;

  @override
  void fire(EnemyComponent target) {}

  /// Spends gold to roll out an Ally [type] (tank/light vehicle/aircraft) -
  /// called from the action panel's build menu. Returns whether it
  /// actually happened.
  bool produceUnit(AllyUnitType type) {
    if (!canProduce) return false;
    final blueprint = game.allyUnitRepository.blueprintFor(type);
    if (!game.gameState.spendGold(blueprint.cost)) return false;
    cooldownRemaining = GameConfig.warFactoryProductionCooldown;
    game.world.spawnAlly(_buildAlly(type));
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (cooldownRemaining > 0) {
      cooldownRemaining = (cooldownRemaining - dt).clamp(0, double.infinity);
    }
  }

  AllyUnitComponent _buildAlly(AllyUnitType type) {
    final blueprint = game.allyUnitRepository.blueprintFor(type);
    return switch (type) {
      AllyUnitType.tank => AllyTankComponent(
        blueprint: blueprint,
        position: position.clone(),
        level: upgradeLevel,
      ),
      AllyUnitType.lightVehicle => AllyLightVehicleComponent(
        blueprint: blueprint,
        position: position.clone(),
        level: upgradeLevel,
      ),
      AllyUnitType.aircraft => AllyAircraftComponent(
        blueprint: blueprint,
        position: position.clone(),
        level: upgradeLevel,
      ),
      AllyUnitType.soldier => throw StateError(
        'War Factory does not build soldiers',
      ),
    };
  }
}
