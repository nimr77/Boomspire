import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../core/combat/team.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../terrain/presentation/cloud_layer_component.dart';
import '../../terrain/presentation/terrain_component.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/presentation/tower_component.dart';
import '../../waves/presentation/wave_director_component.dart';
import 'boomspire_game.dart';
import 'ghost_placement_component.dart';
import 'home_base_component.dart';

/// Root of the game scene graph. Holds the terrain, wave director, active
/// towers and mobile units, and routes arena taps back to the game for
/// tower placement.
class GameWorld extends World
    with TapCallbacks, HasGameReference<BoomspireGame> {
  final List<MobileUnitComponent> activeUnits = [];
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

  void removeTower(TowerComponent tower) {
    activeTowers.remove(tower);
    tower.removeFromParent();
    if (tower.blueprint.type == BuildingType.commandPost) {
      game.enforceSupportedTowerLimits();
    }
  }

  void removeUnit(MobileUnitComponent unit) {
    activeUnits.remove(unit);
    unit.removeFromParent();
  }

  /// Adds any transient visual/audio effect component to the scene.
  void spawn(Component component) => add(component);

  void spawnTower(TowerComponent tower) {
    activeTowers.add(tower);
    add(tower);
  }

  void spawnUnit(MobileUnitComponent unit) {
    activeUnits.add(unit);
    add(unit);
  }

  /// Every live mobile unit whose [Team] is allied with (same side as)
  /// [team] - includes [team]'s own units, since a team is always "allied"
  /// with itself.
  Iterable<MobileUnitComponent> unitsAlliedWith(Team team) => activeUnits.where(
    (u) => !u.destroyed && team.relationTo(u.team) == TeamRelation.ally,
  );

  /// Every live mobile unit whose [Team] is hostile to [team] - this is
  /// what a unit or tower belonging to [team] should be scanning for
  /// targets.
  Iterable<MobileUnitComponent> unitsHostileTo(Team team) => activeUnits.where(
    (u) => !u.destroyed && team.relationTo(u.team) == TeamRelation.enemy,
  );
}
