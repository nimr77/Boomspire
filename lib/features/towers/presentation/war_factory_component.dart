import 'dart:math';

import '../../allies/domain/models/ally_unit_type.dart';
import '../../allies/presentation/ally_aircraft_component.dart';
import '../../allies/presentation/ally_light_vehicle_component.dart';
import '../../allies/presentation/ally_tank_component.dart';
import '../../allies/presentation/ally_unit_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import '../../game_core/domain/models/game_config.dart';
import 'tower_component.dart';

/// Non-combat structure: it never fires (zero range/damage), it instead
/// periodically rolls out a fresh Ally vehicle or aircraft (chosen at
/// random each time) that heads out to hunt down the nearest enemy on its
/// own (see `AllyUnitComponent`).
class WarFactoryComponent extends TowerComponent {
  static const _vehicleTypes = [
    AllyUnitType.tank,
    AllyUnitType.lightVehicle,
    AllyUnitType.aircraft,
  ];

  final Random _random = Random();
  double _spawnTimer = GameConfig.warFactorySpawnInterval;

  WarFactoryComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  @override
  void fire(EnemyComponent target) {}

  @override
  void update(double dt) {
    super.update(dt);
    if (destroyed) return;
    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnTimer = GameConfig.warFactorySpawnInterval;
      final type = _vehicleTypes[_random.nextInt(_vehicleTypes.length)];
      game.world.spawnAlly(_buildAlly(type));
    }
  }

  AllyUnitComponent _buildAlly(AllyUnitType type) {
    final blueprint = game.allyUnitRepository.blueprintFor(type);
    return switch (type) {
      AllyUnitType.tank => AllyTankComponent(
        blueprint: blueprint,
        position: position.clone(),
      ),
      AllyUnitType.lightVehicle => AllyLightVehicleComponent(
        blueprint: blueprint,
        position: position.clone(),
      ),
      AllyUnitType.aircraft => AllyAircraftComponent(
        blueprint: blueprint,
        position: position.clone(),
      ),
      AllyUnitType.soldier => throw StateError(
        'War Factory does not build soldiers',
      ),
    };
  }
}
