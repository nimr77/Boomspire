import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../allies/presentation/ally_unit_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import '../../terrain/presentation/cloud_layer_component.dart';
import '../../terrain/presentation/terrain_component.dart';
import '../../towers/domain/models/tower_type.dart';
import '../../towers/presentation/tower_component.dart';
import '../../waves/presentation/wave_director_component.dart';
import 'boomspire_game.dart';
import 'ghost_placement_component.dart';
import 'home_base_component.dart';

/// Root of the game scene graph. Holds the terrain, wave director, active
/// towers/enemies/ally units, and routes arena taps back to the game for
/// tower placement.
class GameWorld extends World
    with TapCallbacks, HasGameReference<BoomspireGame> {
  final List<EnemyComponent> activeEnemies = [];
  final List<TowerComponent> activeTowers = [];
  final List<AllyUnitComponent> activeAllies = [];

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
    await add(
      HomeBaseComponent(
        position: Vector2(
          game.terrainMap.basePoint.x,
          game.terrainMap.basePoint.y,
        ),
      ),
    );
    await add(GhostPlacementComponent());
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.handleArenaTap(event.localPosition);
  }

  void removeEnemy(EnemyComponent enemy) {
    activeEnemies.remove(enemy);
    enemy.removeFromParent();
  }

  void removeAlly(AllyUnitComponent ally) {
    activeAllies.remove(ally);
    ally.removeFromParent();
  }

  void removeTower(TowerComponent tower) {
    activeTowers.remove(tower);
    tower.removeFromParent();
    if (tower.blueprint.type == TowerType.commandPost) {
      game.enforceSupportedTowerLimits();
    }
  }

  /// Adds any transient visual/audio effect component to the scene.
  void spawn(Component component) => add(component);

  void spawnEnemy(EnemyComponent enemy) {
    activeEnemies.add(enemy);
    add(enemy);
  }

  void spawnAlly(AllyUnitComponent ally) {
    activeAllies.add(ally);
    add(ally);
  }

  void spawnTower(TowerComponent tower) {
    activeTowers.add(tower);
    add(tower);
  }
}
