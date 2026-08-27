import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../../ai_director/domain/models/strategy_directive.dart';
import '../../ai_director/domain/repos/ai_director_repository.dart';
import '../../allies/domain/repos/ally_unit_repository.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../audio/domain/repos/audio_repository.dart';
import '../../enemies/domain/repos/enemy_repository.dart';
import '../../terrain/domain/models/terrain_map.dart';
import '../../terrain/domain/repos/terrain_repository.dart';
import '../../terrain/presentation/cloud_layer_component.dart';
import '../../terrain/presentation/terrain_component.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/domain/models/tower_type.dart';
import '../../towers/domain/models/unit_blueprint.dart';
import '../../towers/domain/models/unit_type.dart';
import '../../towers/domain/repos/building_repository.dart';
import '../../towers/domain/repos/tower_repository.dart';
import '../../towers/presentation/anti_air_tower_component.dart';
import '../../towers/presentation/artillery_bunker_component.dart';
import '../../towers/presentation/cannon_tower_component.dart';
import '../../towers/presentation/command_post_component.dart';
import '../../towers/presentation/laser_tower_component.dart';
import '../../towers/presentation/machine_gun_tower_component.dart';
import '../../towers/presentation/rocket_silo_tower_component.dart';
import '../../towers/presentation/rocket_tower_component.dart';
import '../../towers/presentation/sam_tower_component.dart';
import '../../towers/presentation/tech_lab_component.dart';
import '../../towers/presentation/tower_component.dart';
import '../../towers/presentation/training_center_component.dart';
import '../../towers/presentation/war_factory_component.dart';
import '../../waves/domain/repos/wave_repository.dart';
import '../../waves/presentation/wave_director_component.dart';
import '../domain/models/game_config.dart';
import '../domain/models/game_difficulty.dart';
import '../domain/models/game_scene.dart';
import '../domain/models/game_status.dart';
import '../domain/repos/game_state_repository.dart';
import 'game_world.dart';
import 'ghost_placement_component.dart';
import 'home_base_component.dart';

/// Composition root: wires the domain repositories into a running Flame
/// game, owns the shared "build mode" selection, and mediates tower
/// placement/repair taps coming from [GameWorld].
class BoomspireGame extends FlameGame<GameWorld> {
  /// Caps how many independent shake *impulses* can land in quick
  /// succession (see [shakeCamera]) - once the cap is hit within
  /// [_shakeEventWindow], further triggers just extend/strengthen the
  /// current shake instead of layering another one on top.
  static const _maxConcurrentShakeEvents = 3;

  final TerrainRepository terrainRepository;
  final TowerRepository towerRepository;
  final BuildingRepository buildingRepository;
  final AllyUnitRepository allyUnitRepository;
  final EnemyRepository enemyRepository;
  final WaveRepository waveRepository;
  final AudioRepository audioRepository;
  final GameStateRepository gameState;
  final AiDirectorRepository aiDirector;
  final GameScene scene;
  final GameDifficulty difficulty;

  late TerrainMap terrainMap;

  /// Whether the Tech Lab has been built at least once this run - required
  /// before the Laser Lance can be built (see [canBuildTower]). Stays true
  /// even if the lab is later destroyed/sold, so already-built lasers never
  /// get retroactively locked out.
  bool hasTechLab = false;

  /// Whether a Command Post has been built at least once this run - required
  /// (together with [hasTechLab]) before the SAM Site can be built. Stays
  /// true even if every Command Post is later destroyed/sold.
  bool hasCommandPost = false;
  final ValueNotifier<UnitType?> selectedTowerType = ValueNotifier(null);
  final ValueNotifier<TowerComponent?> selectedTower = ValueNotifier(null);

  final ValueNotifier<String> commanderNote = ValueNotifier('');

  /// A build cell awaiting confirmation - set by the first arena tap while a
  /// tower type is selected (shows a ghost footprint + pulsing range ring,
  /// see [GhostPlacementComponent]) and spends no gold. Tapping the same
  /// cell again commits the build; tapping elsewhere moves the preview.
  final ValueNotifier<Point<int>?> pendingPlacement = ValueNotifier(null);

  /// Set by [GamePage] - lets a Flame overlay (which has no [BuildContext])
  /// ask the host page to leave battle and return to level select.
  VoidCallback? onExitToMenu;

  /// What the enemy AI director wants enemies to prioritize this wave.
  FocusHint enemyFocusHint = FocusHint.nearestTower;
  final Random _shakeRandom = Random();
  double _shakeDuration = 0;
  double _shakeMaxDuration = 0;

  double _shakePower = 0;
  int _shakeEventCount = 0;
  double _shakeEventWindow = 0;

  BoomspireGame({
    required this.terrainRepository,
    required this.towerRepository,
    required this.buildingRepository,
    required this.allyUnitRepository,
    required this.enemyRepository,
    required this.waveRepository,
    required this.audioRepository,
    required this.gameState,
    required this.aiDirector,
    required this.scene,
    this.difficulty = GameDifficulty.normal,
  }) : super(
         world: GameWorld(),
         camera: CameraComponent.withFixedResolution(
           width: GameConfig.arenaWidth,
           height: GameConfig.arenaHeight,
         ),
       );

  /// How many active Command Posts are standing - each one supports one
  /// Artillery Bunker (see [buildLimitFor]).
  int get activeCommandPostCount => towerCountFor(BuildingType.commandPost);

  @override
  Color backgroundColor() => const Color(0xFF14181d);

  /// Leaves the current battle and returns to level select (see
  /// [onExitToMenu]) - used by the game-over/victory "change map" actions
  /// and the in-battle exit button.
  void backToLevelSelect() => onExitToMenu?.call();

  /// Why [type] can't be built right now, or null if it's buildable (gold
  /// permitting) - shown in the build menu's lock overlay/tooltip.
  String? buildBlockReason(UnitType type) {
    if (type == TowerType.laser && !hasTechLab) return 'Requires Tech Lab';
    if (type == TowerType.artilleryBunker && activeCommandPostCount == 0) {
      return 'Requires Command Post';
    }
    if (type == TowerType.sam && !(hasTechLab && hasCommandPost)) {
      return 'Requires Tech Lab & Command Post';
    }
    final limit = buildLimitFor(type);
    if (limit != null && towerCountFor(type) >= limit) {
      return 'Max $limit built';
    }
    return null;
  }

  /// Max simultaneous count allowed for [type], or null if unlimited. The
  /// Tech Lab, Command Post, Training Center, War Factory and Laser Lance
  /// only ever need one; Artillery Bunker rides along with however many
  /// Command Posts are standing (so it too tops out at one); the SAM Site
  /// is capped at two.
  int? buildLimitFor(UnitType type) => switch (type) {
    TowerType.laser => 1,
    TowerType.artilleryBunker => activeCommandPostCount,
    TowerType.sam => 2,
    BuildingType.techLab => 1,
    BuildingType.commandPost => 1,
    BuildingType.trainingCenter => 1,
    BuildingType.warFactory => 1,
    _ => null,
  };

  /// Attaches the anti-rocket point-defense module to the currently-selected
  /// tower, if affordable and not already installed.
  void buyAntiRocketForSelectedTower() {
    final tower = selectedTower.value;
    if (tower == null || tower.antiRocket) return;
    if (!gameState.spendGold(kAntiRocketCost)) return;
    tower.antiRocket = true;
    audioRepository.play(SfxType.buildPlace, volume: 0.6);
  }

  bool canBuildTower(UnitType type) => buildBlockReason(type) == null;

  /// Called whenever a Command Post is destroyed or sold - any Artillery
  /// Bunker built beyond what the remaining Command Posts can still support
  /// is torn down too (most-recently-built first), rather than left
  /// orphaned above the new cap.
  void enforceSupportedTowerLimits() {
    final limit = buildLimitFor(TowerType.artilleryBunker) ?? 0;
    final bunkers = world.activeTowers
        .where((t) => t.blueprint.type == TowerType.artilleryBunker)
        .toList();
    final excess = bunkers.length - limit;
    for (var i = 0; i < excess; i++) {
      bunkers[bunkers.length - 1 - i].destroyBySupportLoss();
    }
  }

  /// Routes an arena tap to selecting a tower under the tap (for the
  /// repair/upgrade/sell action panel), or - if a tower type is selected -
  /// previewing/building on an empty, reachable grid cell. The first tap on
  /// a valid cell only shows the range preview (see [pendingPlacement]); a
  /// second tap on that same cell actually commits the build.
  void handleArenaTap(Vector2 point) {
    if (gameState.status != GameStatus.playing) return;

    final tappedTower = _towerAt(point);
    if (tappedTower != null) {
      selectedTower.value = selectedTower.value == tappedTower
          ? null
          : tappedTower;
      pendingPlacement.value = null;
      return;
    }
    selectedTower.value = null;

    final type = selectedTowerType.value;
    if (type == null) {
      pendingPlacement.value = null;
      return;
    }

    final cell = terrainMap.grid.worldToCell(point);
    if (!_isBuildableCell(cell)) {
      pendingPlacement.value = null;
      return;
    }

    if (pendingPlacement.value == cell) {
      _buildTower(type, point);
      pendingPlacement.value = null;
    } else {
      pendingPlacement.value = cell;
    }
  }

  @override
  Future<void> onLoad() async {
    terrainMap = terrainRepository.loadTerrain(scene: scene);
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    await audioRepository.preload();
    await world.initialize();
  }

  /// Repairs the currently-selected tower (see [selectedTower]) to full HP,
  /// if the player can afford it.
  void repairSelectedTower() {
    final tower = selectedTower.value;
    if (tower == null) return;
    _repairTower(tower);
  }

  void restart() {
    gameState.reset();
    terrainMap = terrainRepository.loadTerrain(scene: scene);
    world.activeEnemies.clear();
    world.activeTowers.clear();
    for (final child in world.children.toList()) {
      if (child is! TerrainComponent) child.removeFromParent();
    }
    world.add(TerrainComponent(terrainMap: terrainMap));
    world.add(WaveDirectorComponent());
    world.add(
      CloudLayerComponent(
        arenaSize: Vector2(terrainMap.arenaWidth, terrainMap.arenaHeight),
      ),
    );
    world.add(
      HomeBaseComponent(
        position: Vector2(terrainMap.basePoint.x, terrainMap.basePoint.y),
      ),
    );
    world.add(GhostPlacementComponent());
    enemyFocusHint = FocusHint.nearestTower;
    commanderNote.value = '';
    selectedTowerType.value = null;
    selectedTower.value = null;
    pendingPlacement.value = null;
    hasTechLab = false;
    hasCommandPost = false;
    _shakeEventCount = 0;
    _shakeEventWindow = 0;
  }

  void selectTowerType(UnitType? type) {
    selectedTowerType.value = selectedTowerType.value == type ? null : type;
    pendingPlacement.value = null;
  }

  /// Sells the currently-selected tower for a partial gold refund and frees
  /// up its grid cell.
  void sellSelectedTower() {
    final tower = selectedTower.value;
    if (tower == null) return;
    gameState.addGold(tower.sellValue);
    terrainMap.grid.setTowerOccupied(tower.col, tower.row, false);
    audioRepository.play(SfxType.towerSell, volume: 0.7);
    selectedTower.value = null;
    world.removeTower(tower);
  }

  /// Nudges the camera briefly whenever something fires - stronger weapons
  /// and shots closer to the camera's focal point (the arena's center)
  /// shake harder, like a real camera would.
  void shakeCamera({required double power, required Vector2 origin}) {
    final focus = Vector2(
      GameConfig.arenaWidth / 2,
      GameConfig.arenaHeight / 2,
    );
    final maxDistance = focus.length;
    final proximity = (1 - origin.distanceTo(focus) / maxDistance).clamp(
      0.2,
      1.0,
    );
    final effectivePower = (power * 0.18 * proximity).clamp(0.0, 14.0);

    if (_shakeEventCount >= _maxConcurrentShakeEvents) {
      // Already at the cap for this short window - rather than layering yet
      // another independent shake on top, just make the current one hit a
      // bit harder and last a bit longer.
      _shakePower = _shakePower > effectivePower ? _shakePower : effectivePower;
      _shakeMaxDuration = (_shakeMaxDuration + 0.06).clamp(0.0, 0.8);
      _shakeDuration = _shakeMaxDuration;
      return;
    }

    if (effectivePower < _shakePower) return;
    _shakePower = effectivePower;
    _shakeMaxDuration = _shakeDuration = 0.1 + effectivePower * 0.01;
    _shakeEventCount++;
    _shakeEventWindow = 0.6;
  }

  /// How many of [type] are currently standing on the battlefield.
  int towerCountFor(UnitType type) =>
      world.activeTowers.where((t) => t.blueprint.type == type).length;

  @override
  void update(double dt) {
    super.update(dt);
    if (_shakeEventWindow > 0) {
      _shakeEventWindow -= dt;
      if (_shakeEventWindow <= 0) _shakeEventCount = 0;
    }
    if (_shakeDuration <= 0) return;
    _shakeDuration = (_shakeDuration - dt).clamp(0.0, _shakeMaxDuration);
    if (_shakeDuration <= 0) {
      camera.viewfinder.position = Vector2.zero();
      _shakePower = 0;
      return;
    }
    final falloff = _shakeDuration / _shakeMaxDuration;
    camera.viewfinder.position =
        Vector2(
          _shakeRandom.nextDouble() * 2 - 1,
          _shakeRandom.nextDouble() * 2 - 1,
        ) *
        (_shakePower * falloff);
  }

  /// Upgrades the currently-selected tower by one tier, if affordable and
  /// not already at the maximum tier.
  void upgradeSelectedTower() {
    final tower = selectedTower.value;
    if (tower == null || !tower.canUpgrade) return;
    if (!gameState.spendGold(tower.upgradeCost)) return;
    tower.upgrade();
  }

  void _buildTower(UnitType type, Vector2 point) {
    final grid = terrainMap.grid;
    final cell = grid.worldToCell(point);
    if (!_isBuildableCell(cell)) return;

    final blueprint = blueprintFor(type);
    if (gameState.gold < blueprint.cost) return;
    if (!canBuildTower(type)) return;

    // Provisionally occupy the cell and make sure ground enemies can still
    // reach the base before actually charging gold - never allow a fully
    // sealed maze.
    final spawnCells = terrainMap.spawnPoints
        .map((sp) => grid.worldToCell(Vector2(sp.x, sp.y)))
        .toSet();
    final baseCell = grid.worldToCell(
      Vector2(terrainMap.basePoint.x, terrainMap.basePoint.y),
    );
    grid.setTowerOccupied(cell.x, cell.y, true);
    if (!spawnCells.every((sc) => grid.isReachable(sc, baseCell))) {
      grid.setTowerOccupied(cell.x, cell.y, false);
      return;
    }
    if (!gameState.spendGold(blueprint.cost)) {
      grid.setTowerOccupied(cell.x, cell.y, false);
      return;
    }

    world.spawnTower(
      _createTower(type, grid.cellCenter(cell), grid.cellSize, blueprint),
    );
    if (type == BuildingType.techLab) hasTechLab = true;
    if (type == BuildingType.commandPost) hasCommandPost = true;
    audioRepository.play(SfxType.buildPlace, volume: 0.7);
    selectedTowerType.value = null;
  }

  /// Looks up [type]'s stats from whichever repository actually owns it -
  /// the combat tower catalog or the support building catalog.
  UnitBlueprint blueprintFor(UnitType type) => type is BuildingType
      ? buildingRepository.blueprintFor(type)
      : towerRepository.blueprintFor(type as TowerType);

  TowerComponent _createTower(
    UnitType type,
    Vector2 position,
    double cellSize,
    UnitBlueprint blueprint,
  ) {
    return switch (type) {
      TowerType.machineGun => MachineGunTowerComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      TowerType.rocket => RocketTowerComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      TowerType.cannon => CannonTowerComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      TowerType.antiAir => AntiAirTowerComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      TowerType.laser => LaserTowerComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      TowerType.rocketSilo => RocketSiloTowerComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      TowerType.artilleryBunker => ArtilleryBunkerComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      TowerType.sam => SamTowerComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      BuildingType.techLab => TechLabComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      BuildingType.commandPost => CommandPostComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      BuildingType.trainingCenter => TrainingCenterComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      BuildingType.warFactory => WarFactoryComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      _ => throw ArgumentError('Unknown unit type: $type'),
    };
  }

  /// Whether [cell] is empty ground that isn't a spawn point or the home
  /// base - used both for the tap-to-preview ghost and the actual build.
  bool _isBuildableCell(Point<int> cell) {
    final grid = terrainMap.grid;
    if (grid.isBlocked(cell.x, cell.y)) return false;

    final spawnCells = terrainMap.spawnPoints
        .map((sp) => grid.worldToCell(Vector2(sp.x, sp.y)))
        .toSet();
    final baseCell = grid.worldToCell(
      Vector2(terrainMap.basePoint.x, terrainMap.basePoint.y),
    );
    return !spawnCells.contains(cell) && cell != baseCell;
  }

  void _repairTower(TowerComponent tower) {
    final cost = tower.repairCost;
    if (cost <= 0) return;
    if (!gameState.spendGold(cost)) return;
    tower.repair(tower.maxHp);
    audioRepository.play(SfxType.towerRepair, volume: 0.7);
  }

  TowerComponent? _towerAt(Vector2 point) {
    for (final tower in world.activeTowers) {
      final half = tower.size.x / 2;
      if ((point.x - tower.position.x).abs() <= half &&
          (point.y - tower.position.y).abs() <= half) {
        return tower;
      }
    }
    return null;
  }
}
