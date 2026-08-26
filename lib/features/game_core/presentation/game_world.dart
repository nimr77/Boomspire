import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../enemies/presentation/enemy_component.dart';
import '../../terrain/presentation/terrain_component.dart';
import '../../towers/presentation/tower_component.dart';
import '../../waves/presentation/wave_director_component.dart';
import 'circuit_defense_game.dart';

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
  }

  void spawnEnemy(EnemyComponent enemy) {
    activeEnemies.add(enemy);
    add(enemy);
  }

  void removeEnemy(EnemyComponent enemy) {
    activeEnemies.remove(enemy);
    enemy.removeFromParent();
  }

  void spawnTower(TowerComponent tower) {
    activeTowers.add(tower);
    add(tower);
  }

  /// Adds any transient visual/audio effect component to the scene.
  void spawn(Component component) => add(component);

  @override
  void onTapDown(TapDownEvent event) {
    game.handleArenaTap(event.localPosition);
  }
}
