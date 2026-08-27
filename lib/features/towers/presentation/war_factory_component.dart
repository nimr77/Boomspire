import '../../../core/combat/mobile_unit_blueprint.dart';
import '../../../core/combat/unit_kind.dart';
import '../../allies/presentation/ally_aircraft_component.dart';
import '../../allies/presentation/ally_light_vehicle_component.dart';
import '../../allies/presentation/ally_rocket_barrage_component.dart';
import '../../allies/presentation/ally_tank_component.dart';
import '../../allies/presentation/ally_unit_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import '../../game_core/domain/models/game_config.dart';
import 'tower_component.dart';

/// Non-combat structure: it never fires (zero range/damage). Instead, the
/// player mans it via the build menu shown when it's selected on the
/// battlefield (see `TowerActionPanel`), spending gold to roll out an Ally
/// tank, light vehicle, Rocket Barrage or aircraft of their choosing that
/// heads out to hunt down the nearest enemy on its own (see
/// `AllyUnitComponent`).
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
      game.unitRepository.blueprintFor(game.playerTeam, kind).cost;

  @override
  void fire(EnemyComponent target) {}

  /// Spends gold to roll out an Ally unit of the given [kind] (tank/light
  /// vehicle/Rocket Barrage/aircraft) - called from the action panel's
  /// build menu. Returns whether it actually happened.
  bool produceUnit(UnitKind kind) {
    if (!canProduce) return false;
    final blueprint = game.unitRepository.blueprintFor(game.playerTeam, kind);
    if (!game.gameState.spendGold(blueprint.cost)) return false;
    cooldownRemaining = GameConfig.warFactoryProductionCooldown;
    game.world.spawnAlly(_buildAlly(kind, blueprint));
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (cooldownRemaining > 0) {
      cooldownRemaining = (cooldownRemaining - dt).clamp(0, double.infinity);
    }
  }

  AllyUnitComponent _buildAlly(UnitKind kind, MobileUnitBlueprint blueprint) {
    return switch (kind) {
      UnitKind.tank => AllyTankComponent(
        blueprint: blueprint,
        position: position.clone(),
        team: game.playerTeam,
        level: upgradeLevel,
      ),
      UnitKind.lightVehicle => AllyLightVehicleComponent(
        blueprint: blueprint,
        position: position.clone(),
        team: game.playerTeam,
        level: upgradeLevel,
      ),
      UnitKind.aircraft => AllyAircraftComponent(
        blueprint: blueprint,
        position: position.clone(),
        team: game.playerTeam,
        level: upgradeLevel,
      ),
      UnitKind.rocketBarrage => AllyRocketBarrageComponent(
        blueprint: blueprint,
        position: position.clone(),
        team: game.playerTeam,
        level: upgradeLevel,
      ),
      _ => throw StateError('War Factory does not build $kind'),
    };
  }
}

