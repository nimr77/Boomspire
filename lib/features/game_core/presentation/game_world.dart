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
import 'boomspire_game.dart';
import 'ghost_placement_component.dart';
import 'home_base_component.dart';
import 'resource_node_component.dart';

/// Root of the game scene graph. Holds the terrain, wave director, active
/// towers and mobile units, and routes arena taps back to the game for
/// tower placement.
class GameWorld extends World
    with
        TapCallbacks,
        KeyboardHandler,
        PointerMoveCallbacks,
        HasGameReference<BoomspireGame> {
  /// World-space pixels/second the camera pans at while a key or a screen
  /// edge is engaged - matches classic RTS edge-scroll speed rather than
  /// easing toward a target.
  static const _panSpeed = 640.0;

  /// How close the pointer has to sit to the viewport's edge (in canvas
  /// pixels) before edge-scroll kicks in.
  static const _edgeMargin = 28.0;

  final List<MobileUnitComponent> activeUnits = [];
  final List<TowerComponent> activeTowers = [];

  /// Top-left world coordinate the viewport currently shows - `BoomspireGame`
  /// layers its camera-shake jitter on top of this every frame rather than
  /// fighting over `camera.viewfinder.position` directly. Panning is a no-op
  /// (stays zero) whenever the whole map already fits on screen, which is
  /// every wave-defense scene today.
  Vector2 cameraPosition = Vector2.zero();

  final Set<LogicalKeyboardKey> _pressedKeys = {};
  Vector2? _pointerCanvasPosition;

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
  void onPointerMove(PointerMoveEvent event) {
    _pointerCanvasPosition = event.canvasPosition;
  }

  @override
  void onPointerMoveStop(PointerMoveEvent event) {
    _pointerCanvasPosition = null;
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.handleArenaTap(event.localPosition);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _panCamera(dt);
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

  /// Free-scrolling RTS camera: arrow keys/WASD and edge-of-screen mouse
  /// panning both move [cameraPosition] at a constant screen-space speed
  /// (C&C-Generals-style, not an eased pan), clamped so the viewport never
  /// shows past the map's edge.
  void _panCamera(double dt) {
    final viewport = game.camera.viewport.size;
    final maxX = (game.terrainMap.arenaWidth - viewport.x).clamp(
      0.0,
      double.infinity,
    );
    final maxY = (game.terrainMap.arenaHeight - viewport.y).clamp(
      0.0,
      double.infinity,
    );
    if (maxX <= 0 && maxY <= 0) {
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

    final pointer = _pointerCanvasPosition;
    if (pointer != null) {
      if (pointer.x <= _edgeMargin) direction.x -= 1;
      if (pointer.x >= viewport.x - _edgeMargin) direction.x += 1;
      if (pointer.y <= _edgeMargin) direction.y -= 1;
      if (pointer.y >= viewport.y - _edgeMargin) direction.y += 1;
    }

    if (direction.length2 == 0) return;
    final delta = direction.normalized() * _panSpeed * dt;
    cameraPosition = Vector2(
      (cameraPosition.x + delta.x).clamp(0.0, maxX),
      (cameraPosition.y + delta.y).clamp(0.0, maxY),
    );
  }
}
