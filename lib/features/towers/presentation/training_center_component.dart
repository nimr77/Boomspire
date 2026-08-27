import '../../allies/domain/models/ally_unit_type.dart';
import '../../allies/presentation/ally_soldier_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import '../../game_core/domain/models/game_config.dart';
import 'tower_component.dart';

/// Non-combat structure: it never fires (zero range/damage), it instead
/// periodically musters a fresh Ally Soldier that walks out to hunt down
/// the nearest enemy on its own (see `AllyUnitComponent`).
class TrainingCenterComponent extends TowerComponent {
  double _spawnTimer = GameConfig.trainingCenterSpawnInterval;

  TrainingCenterComponent({
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
      _spawnTimer = GameConfig.trainingCenterSpawnInterval;
      game.world.spawnAlly(
        AllySoldierComponent(
          blueprint: game.allyUnitRepository.blueprintFor(
            AllyUnitType.soldier,
          ),
          position: position.clone(),
        ),
      );
    }
  }
}
