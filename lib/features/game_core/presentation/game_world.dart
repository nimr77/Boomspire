import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart';

import '../../../core/combat/attackable.dart';
import '../../../core/combat/team.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../terrain/presentation/cloud_layer_component.dart';
import '../../terrain/presentation/terrain_component.dart';
import '../../terrain/presentation/wind_effect_component.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/domain/targeting/target_assignment_computer.dart';
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

  static const double _targetComputeInterval = 0.2;
  final List<MobileUnitComponent> activeUnits = [];
  final List<TowerComponent> activeTowers = [];

  final List<ResourceNodeComponent> activeResourceNodes = [];

  /// How many of each team's towers currently have a given target (a
  /// mobile unit or an enemy tower/building) as
  /// [TowerComponent.currentTarget], refreshed once per frame (see
  /// [_refreshTargeterCounts]) from the previous frame's targeting choices.
  /// A single O(towers) pass shared by every tower's `_acquireTarget`, so
  /// avoiding target dog-piling never costs an O(towers²) rescan.
  final Map<Attackable, int> targeterCounts = {};

  /// Latest focus-fire-aware target pick per tower (keyed by
  /// `identityHashCode`), computed on a background isolate every
  /// [_targetComputeInterval] seconds - see [_refreshTargetAssignments] and
  /// [suggestedTargetFor]. Empty until the first round-trip completes.
  final Map<int, int?> _targetAssignments = {};

  /// `identityHashCode` -> live unit, rebuilt once per frame so
  /// [suggestedTargetFor] can resolve a background result back to an actual
  /// component in O(1) without the isolate ever touching real game objects.
  Map<int, MobileUnitComponent> _unitsById = {};

  /// Same as [_unitsById] but for towers/buildings, since a background
  /// suggestion can now point at either kind of target.
  Map<int, TowerComponent> _towersById = {};
  double _targetComputeTimer = 0;
  bool _targetComputeInFlight = false;

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
    await add(
      WindEffectComponent(
        arenaSize: Vector2(
          game.terrainMap.arenaWidth,
          game.terrainMap.arenaHeight,
        ),
        biome: game.scene.biome,
      ),
    );
    // Disabled for now - the procedural ambient loops need rework before
    // this is worth turning back on (see AmbientWeatherAudioComponent).
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
      final node = ResourceNodeComponent(position: Vector2(point.x, point.y));
      activeResourceNodes.add(node);
      await add(node);
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

  /// The target [tower] should shoot next, per the last completed
  /// background focus-fire scan (see [_refreshTargetAssignments]) - `null`
  /// if nothing has been computed yet, the suggestion has since
  /// died/despawned, or the last scan simply found nothing in range for it.
  Attackable? suggestedTargetFor(TowerComponent tower) {
    final id = _targetAssignments[identityHashCode(tower)];
    if (id == null) return null;
    final unit = _unitsById[id];
    if (unit != null) return (unit.destroyed || !unit.isMounted) ? null : unit;
    final other = _towersById[id];
    if (other == null || other.destroyed || !other.isMounted) return null;
    return other;
  }

  /// Every live tower/building whose [TowerComponent.owner] is hostile to
  /// [team] - towers/buildings are valid targets too, scored exactly like a
  /// stationary ground unit (see [computeTargetAssignments]); a tower's own
  /// [TowerComponent.attackDomains] is what actually decides whether it's
  /// allowed to hit one (e.g. an anti-air/SAM site only attacks
  /// [UnitDomain.air] and so never targets a ground-domain tower).
  Iterable<TowerComponent> towersHostileTo(Team team) => activeTowers.where(
    (t) => !t.destroyed && team.relationTo(t.owner) == TeamRelation.enemy,
  );

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
    _refreshTargeterCounts();
    _unitsById = {for (final u in activeUnits) identityHashCode(u): u};
    _towersById = {for (final t in activeTowers) identityHashCode(t): t};
    _targetComputeTimer -= dt;
    if (_targetComputeTimer <= 0 && !_targetComputeInFlight) {
      _targetComputeTimer = _targetComputeInterval;
      unawaited(_refreshTargetAssignments());
    }
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

  /// Runs [computeTargetAssignments] on a background isolate via `compute()`
  /// - the actual O(towers × enemies) focus-fire scan, taken off the main
  /// isolate so it never competes with rendering/input on a big battlefield.
  /// Towers only ever read the *previous* completed result through
  /// [suggestedTargetFor]; while a scan is in flight (or before the first
  /// one lands) `TowerComponent._acquireTarget` falls back to its own
  /// synchronous copy of the same scoring, so nothing waits on the
  /// round-trip to react.
  Future<void> _refreshTargetAssignments() async {
    _targetComputeInFlight = true;
    try {
      final snapshot = TargetingSnapshot(
        towers: [
          for (final t in activeTowers)
            TowerSnapshot(
              id: identityHashCode(t),
              x: t.position.x,
              y: t.position.y,
              minRange: t.blueprint.minRange,
              range: t.effectiveRange,
              damage: t.effectiveDamage,
              ownerId: t.owner.id,
              currentTargetId: t.currentTarget == null
                  ? null
                  : identityHashCode(t.currentTarget!),
              attackDomains: t.attackDomains,
            ),
        ],
        // Every hostile candidate a tower could shoot - mobile units plus
        // enemy towers/buildings (treated as stationary ground targets),
        // see [towersHostileTo].
        targets: [
          for (final u in activeUnits)
            if (!u.destroyed)
              TargetSnapshot(
                id: identityHashCode(u),
                x: u.position.x,
                y: u.position.y,
                health: u.health,
                healthRatio: u.healthRatio,
                teamId: u.team.id,
                domain: u.domain,
              ),
          for (final t in activeTowers)
            if (!t.destroyed)
              TargetSnapshot(
                id: identityHashCode(t),
                x: t.position.x,
                y: t.position.y,
                health: t.health,
                healthRatio: t.healthRatio,
                teamId: t.owner.id,
                domain: t.domain,
              ),
        ],
      );
      final result = await compute(computeTargetAssignments, snapshot);
      _targetAssignments
        ..clear()
        ..addAll(result);
    } finally {
      _targetComputeInFlight = false;
    }
  }

  /// Rebuilds [targeterCounts] from each tower's [TowerComponent.currentTarget]
  /// as of the end of the previous frame - a single O(towers) pass run once
  /// at the top of this frame's [update], before any tower re-evaluates its
  /// own target, so the "how contested is this candidate" check every
  /// tower's `_acquireTarget` does stays O(1) instead of every tower
  /// independently rescanning every other tower (which would be
  /// O(towers²) per frame).
  void _refreshTargeterCounts() {
    targeterCounts.clear();
    for (final tower in activeTowers) {
      final target = tower.currentTarget;
      if (target != null) {
        targeterCounts[target] = (targeterCounts[target] ?? 0) + 1;
      }
    }
  }
}
