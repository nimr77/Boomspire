import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../enemies/presentation/enemy_component.dart';
import '../../terrain/presentation/cloud_layer_component.dart';
import '../../terrain/presentation/terrain_component.dart';
import '../../towers/presentation/tower_component.dart';
import '../../waves/presentation/wave_director_component.dart';
import 'circuit_defense_game.dart';
import 'home_base_component.dart';
import 'spawn_indicator_component.dart';

/// Root of the game scene graph. Holds the terrain, wave director, active
/// towers/enemies, and routes arena taps back to the game for tower
/// placement.
class GameWorld extends World
    with TapCallbacks, HasGameReference<CircuitDefenseGame> {
  final List<EnemyComponent> activeEnemies = [];
  final List<TowerComponent> activeTowers = [];

  Future<void> initialize() async {
    await add(TerrainComponent(terrainMap: game.terrainMap));
    await add(WaveDirectorComponent());
    await add(
      CloudLayerComponent(
        arenaSize: Vector2(
          game.terrainMap.arenaWidth,
          game.terrainMap.arenaHeight,
        ),
      ),
    );
    for (final spawn in game.terrainMap.spawnPoints) {
      await add(
        SpawnIndicatorComponent(
          position: Vector2(spawn.x, spawn.y - 34),
        ),
      );
    }
    await add(
      HomeBaseComponent(
        position: Vector2(
          game.terrainMap.basePoint.x,
          game.terrainMap.basePoint.y,
        ),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.handleArenaTap(event.localPosition);
  }

  void removeEnemy(EnemyComponent enemy) {
    activeEnemies.remove(enemy);
    enemy.removeFromParent();
  }

  void removeTower(TowerComponent tower) {
    activeTowers.remove(tower);
    tower.removeFromParent();
  }

  /// Adds any transient visual/audio effect component to the scene.
  void spawn(Component component) => add(component);

  void spawnEnemy(EnemyComponent enemy) {
    activeEnemies.add(enemy);
    add(enemy);
  }

  void spawnTower(TowerComponent tower) {
    activeTowers.add(tower);
    add(tower);
  }
}
