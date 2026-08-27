import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';

import '../../../core/combat/team.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../terrain/presentation/cloud_layer_component.dart';
import '../../terrain/presentation/terrain_component.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/presentation/tower_component.dart';
import '../../waves/presentation/wave_director_component.dart';
import '../domain/models/game_scene.dart';
import 'ai_home_base_component.dart';
import 'ai_skirmish_controller_component.dart';
import 'boomspire_game.dart';
import 'ghost_placement_component.dart';
import 'home_base_component.dart';
import 'resource_node_component.dart';

/// Root of the game scene graph. Holds the terrain, wave director, active
/// towers and mobile units, and routes arena taps back to the game for
/// tower placement.
class GameWorld extends World
    with TapCallbacks, KeyboardHandler, HasGameReference<BoomspireGame> {
  /// World-space pixels/second the camera pans at while a key is held -
  /// matches classic RTS edge-scroll speed rather than easing toward a
  /// target.
  static const _panSpeed = 640.0;

  final List<MobileUnitComponent> activeUnits = [];
  final List<TowerComponent> activeTowers = [];

  /// The human player's base - always set once [initialize] has run.
  HomeBaseComponent? playerHomeBase;

  /// The AI opponent's base - only set for a [GameMode.skirmish] match.
  AiHomeBaseComponent? aiHomeBase;

  /// Top-left world coordinate the viewport currently shows - `BoomspireGame`
  /// layers its camera-shake jitter on top of this every frame rather than
  /// fighting over `camera.viewfinder.position` directly. Panning is a no-op
  /// (stays zero) whenever the whole map already fits on screen, which is
  /// every wave-defense scene today.
  Vector2 cameraPosition = Vector2.zero();

  /// True while the player is dragging the camera with the middle mouse
  /// button (see `GamePage`'s `Listener` - Flame's own drag/pointer-move
  /// callbacks can't distinguish mouse buttons, so the button-down/up
  /// detection lives at the Flutter widget layer and just flips this flag).
  /// Keyboard panning is suppressed while this is true so the two don't
  /// fight over [cameraPosition].
  bool freePanning = false;

  final Set<LogicalKeyboardKey> _pressedKeys = {};

  Future<void> initialize() async {
    await add(TerrainComponent(terrainMap: game.terrainMap));
    final skirmish = game.scene.mode == GameMode.skirmish;
    if (!skirmish) {
      await add(WaveDirectorComponent());
    }
    await add(
      CloudLayerComponent(
        arenaSize: Vector2(
          game.terrainMap.arenaWidth,
          game.terrainMap.arenaHeight,
        ),
      ),
    );
    playerHomeBase = HomeBaseComponent(
      position: Vector2(
        game.terrainMap.basePoint.x,
        game.terrainMap.basePoint.y,
      ),
      owner: game.playerTeam,
    );
    await add(playerHomeBase!);
    if (skirmish) {
      final secondary = game.terrainMap.secondaryBasePoint;
      if (secondary != null) {
        aiHomeBase = AiHomeBaseComponent(
          position: Vector2(secondary.x, secondary.y),
        );
        await add(aiHomeBase!);
      }
      await add(AiSkirmishControllerComponent());
    } else {
      aiHomeBase = null;
    }
    await add(GhostPlacementComponent());
    for (final point in game.terrainMap.resourceNodePoints) {
      await add(ResourceNodeComponent(position: Vector2(point.x, point.y)));
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _pressedKeys
      ..clear()
      ..addAll(keysPressed);
    return true;
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

  @override
  void update(double dt) {
    super.update(dt);
    _panCamera(dt);
  }

  /// The farthest [cameraPosition] can go on each axis before the viewport
  /// would show past the map's edge - `Vector2.zero()` on an axis whenever
  /// the whole map already fits on screen along it.
  Vector2 _cameraBounds() {
    final viewport = game.camera.viewport.virtualSize;
    return Vector2(
      (game.terrainMap.arenaWidth - viewport.x).clamp(0.0, double.infinity),
      (game.terrainMap.arenaHeight - viewport.y).clamp(0.0, double.infinity),
    );
  }

  /// Nudges [cameraPosition] by a raw canvas-space delta (already scaled
  /// into the camera's fixed-resolution coordinate space by the caller),
  /// clamped to the map's edges. Used by `GamePage`'s middle-mouse-drag
  /// free-pan handler - subtracting the pointer's delta gives the usual
  /// "grab the map and drag it" feel (drag right reveals what's to the
  /// left).
  void panBy(Vector2 canvasDelta) {
    final bounds = _cameraBounds();
    cameraPosition = Vector2(
      (cameraPosition.x - canvasDelta.x).clamp(0.0, bounds.x),
      (cameraPosition.y - canvasDelta.y).clamp(0.0, bounds.y),
    );
  }

  /// Centers the camera on a world point (clamped to the map's edges) -
  /// used when the player taps the minimap.
  void centerCameraOn(Vector2 worldPoint) {
    final viewport = game.camera.viewport.virtualSize;
    final bounds = _cameraBounds();
    cameraPosition = Vector2(
      (worldPoint.x - viewport.x / 2).clamp(0.0, bounds.x),
      (worldPoint.y - viewport.y / 2).clamp(0.0, bounds.y),
    );
  }

  /// Free-scrolling RTS camera: arrow keys/WASD move [cameraPosition] at a
  /// constant screen-space speed (C&C-Generals-style, not an eased pan),
  /// clamped so the viewport never shows past the map's edge. A no-op while
  /// [freePanning] (middle-mouse drag) owns [cameraPosition] instead.
  void _panCamera(double dt) {
    if (freePanning) return;
    final bounds = _cameraBounds();
    if (bounds.x <= 0 && bounds.y <= 0) {
      cameraPosition = Vector2.zero();
      return;
    }

    final direction = Vector2.zero();
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp) ||
        _pressedKeys.contains(LogicalKeyboardKey.keyW)) {
      direction.y -= 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown) ||
        _pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      direction.y += 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowLeft) ||
        _pressedKeys.contains(LogicalKeyboardKey.keyA)) {
      direction.x -= 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowRight) ||
        _pressedKeys.contains(LogicalKeyboardKey.keyD)) {
      direction.x += 1;
    }

    if (direction.length2 == 0) return;
    final delta = direction.normalized() * _panSpeed * dt;
    cameraPosition = Vector2(
      (cameraPosition.x + delta.x).clamp(0.0, bounds.x),
      (cameraPosition.y + delta.y).clamp(0.0, bounds.y),
    );
  }
}
