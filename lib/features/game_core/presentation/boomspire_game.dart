import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../../../core/combat/attackable.dart';
import '../../../core/combat/mobile_unit_repository.dart';
import '../../../core/combat/team.dart';
import '../../ai_director/domain/models/strategy_directive.dart';
import '../../ai_director/domain/repos/ai_director_repository.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../audio/domain/repos/audio_repository.dart';
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
import '../../towers/presentation/gold_mine_component.dart';
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
import '../domain/models/ai_economy.dart';
import '../domain/models/game_config.dart';
import '../domain/models/game_difficulty.dart';
import '../domain/models/game_scene.dart';
import '../domain/models/game_status.dart';
import '../domain/repos/game_state_repository.dart';
import 'ai_home_base_component.dart';
import 'ai_skirmish_controller_component.dart';
import 'game_world.dart';
import 'ghost_placement_component.dart';
import 'home_base_component.dart';
import 'minimap_component.dart';
import 'resource_node_component.dart';

/// Composition root: wires the domain repositories into a running Flame
/// game, owns the shared "build mode" selection, and mediates tower
/// placement/repair taps coming from [GameWorld].
class BoomspireGame extends FlameGame<GameWorld>
    with HasKeyboardHandlerComponents<GameWorld> {
  /// Caps how many independent shake *impulses* can land in quick
  /// succession (see [shakeCamera]) - once the cap is hit within
  /// [_shakeEventWindow], further triggers just extend/strengthen the
  /// current shake instead of layering another one on top.
  static const _maxConcurrentShakeEvents = 3;

  final TerrainRepository terrainRepository;
  final TowerRepository towerRepository;
  final BuildingRepository buildingRepository;
  final MobileUnitRepository unitRepository;
  final WaveRepository waveRepository;
  final AudioRepository audioRepository;
  final GameStateRepository gameState;
  final AiDirectorRepository aiDirector;
  final GameScene scene;
  final GameDifficulty difficulty;

  /// Which side the human player is playing as - carries the color every
  /// ally unit/HP bar is tinted with. Defaults to the single-player color;
  /// a future networked match assigns each connected player their own
  /// [Team].
  Team playerTeam = Team.defaultPlayer;

  /// Non-null only for a [GameMode.skirmish] match - the Gemini-directed
  /// opponent's [Team]/wallet, set up by [_setupSkirmishState] in both
  /// [onLoad] and [restart].
  Team? aiTeam;
  AiEconomy? aiEconomy;

  late TerrainMap terrainMap;

  /// Whether each team (keyed by `Team.id`) has built a Tech Lab at least
  /// once this run - required before that team can build a Laser Lance (see
  /// [canBuildTower]). Stays true even if the lab is later destroyed/sold,
  /// so already-built lasers never get retroactively locked out. Per-team
  /// so the AI's own prerequisite chain is independent of the player's.
  final Map<int, bool> _hasTechLabByTeam = {};

  /// Whether each team has built a Command Post at least once this run -
  /// required (together with a Tech Lab) before that team can build a SAM
  /// Site. Stays true even if every Command Post is later destroyed/sold.
  final Map<int, bool> _hasCommandPostByTeam = {};
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
    required this.unitRepository,
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

  /// How many active Command Posts [owner] has standing - each one supports
  /// one Artillery Bunker for that same owner (see [buildLimitFor]).
  int commandPostCountFor(Team owner) =>
      towerCountFor(BuildingType.commandPost, owner: owner);

  bool hasTechLabFor(Team owner) => _hasTechLabByTeam[owner.id] ?? false;

  bool hasCommandPostFor(Team owner) =>
      _hasCommandPostByTeam[owner.id] ?? false;

  /// Sum of every standing Gold Mine's kill-gold bonus (see
  /// `GoldMineComponent.killGoldBonus`) - added on top of the normal
  /// escalating streak bonus for every kill (see
  /// `GameStateRepository.addKillGold`).
  double get goldMineKillGoldBonus => world.activeTowers
      .whereType<GoldMineComponent>()
      .fold(0.0, (sum, mine) => sum + mine.killGoldBonus);

  @override
  Color backgroundColor() => const Color(0xFF14181d);

  /// Leaves the current battle and returns to level select (see
  /// [onExitToMenu]) - used by the game-over/victory "change map" actions
  /// and the in-battle exit button.
  void backToLevelSelect() => onExitToMenu?.call();

  /// Where a unit belonging to [team] should march toward to assault the
  /// opposing base - the human player's base if [team] is the AI, or the
  /// AI's base if [team] is the player. Null if there's no such base (e.g.
  /// [team] is neither side, or this isn't a skirmish match).
  Vector2? baseTargetFor(Team team) {
    if (aiTeam == null) return null;
    if (team.id == aiTeam!.id) {
      return Vector2(terrainMap.basePoint.x, terrainMap.basePoint.y);
    }
    if (team.id == playerTeam.id) {
      final base = world.aiHomeBase;
      return base != null && base.isMounted ? base.position : null;
    }
    return null;
  }

  /// Looks up [type]'s stats from whichever repository actually owns it -
  /// the combat tower catalog or the support building catalog.
  UnitBlueprint blueprintFor(UnitType type) => type is BuildingType
      ? buildingRepository.blueprintFor(type)
      : towerRepository.blueprintFor(type as TowerType);

  /// Why [type] can't be built right now for [owner] (defaults to the human
  /// player), or null if it's buildable (gold permitting) - shown in the
  /// build menu's lock overlay/tooltip, and used identically by the AI
  /// skirmish opponent so both sides are bound by the same rules.
  String? buildBlockReason(UnitType type, {Team? owner}) {
    final builder = owner ?? playerTeam;
    if (type == TowerType.laser && !hasTechLabFor(builder)) {
      return 'Requires Tech Lab';
    }
    if (type == TowerType.artilleryBunker &&
        commandPostCountFor(builder) == 0) {
      return 'Requires Command Post';
    }
    if (type == TowerType.sam &&
        !(hasTechLabFor(builder) && hasCommandPostFor(builder))) {
      return 'Requires Tech Lab & Command Post';
    }
    // Score-gated unlocks are a human-player-only concept - the AI has no
    // "score", so it's bound only by gold, prerequisites and per-type
    // limits.
    if (builder.id == playerTeam.id) {
      if (type == BuildingType.trainingCenter &&
          gameState.currentScore < GameConfig.trainingCenterUnlockScore) {
        return 'Requires ${GameConfig.trainingCenterUnlockScore} score';
      }
      if (type == BuildingType.warFactory &&
          gameState.currentScore < GameConfig.warFactoryUnlockScore) {
        return 'Requires ${GameConfig.warFactoryUnlockScore} score';
      }
    }
    final limit = buildLimitFor(type, owner: builder);
    if (limit != null && towerCountFor(type, owner: builder) >= limit) {
      return 'Max $limit built';
    }
    return null;
  }

  /// Max simultaneous count allowed for [type] per-owner, or null if
  /// unlimited. The Tech Lab, Command Post, Training Center, War Factory,
  /// Gold Mine and Laser Lance only ever need one; Artillery Bunker rides
  /// along with however many Command Posts that same owner has standing (so
  /// it too tops out at one per Command Post); the SAM Site is capped at
  /// two.
  int? buildLimitFor(UnitType type, {Team? owner}) => switch (type) {
    TowerType.laser => 1,
    TowerType.artilleryBunker => commandPostCountFor(owner ?? playerTeam),
    TowerType.sam => 2,
    BuildingType.techLab => 1,
    BuildingType.commandPost => 1,
    BuildingType.trainingCenter => 1,
    BuildingType.warFactory => 1,
    BuildingType.goldMine => 1,
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

  bool canBuildTower(UnitType type, {Team? owner}) =>
      buildBlockReason(type, owner: owner) == null;

  /// How much gold [owner] currently has - the player's `gameState` wallet,
  /// or the AI's `aiEconomy` wallet (0 if there is none, e.g. outside
  /// skirmish mode).
  int goldFor(Team owner) =>
      owner.id == playerTeam.id ? gameState.gold : (aiEconomy?.gold ?? 0);

  /// Spends [amount] from whichever wallet [owner] draws from (see
  /// [goldFor]) - returns whether it actually happened.
  bool spendGoldFor(Team owner, int amount) => owner.id == playerTeam.id
      ? gameState.spendGold(amount)
      : (aiEconomy?.spendGold(amount) ?? false);

  /// Attempts to build [type] at [point] for [owner] - the single shared
  /// path used by both the player's own build menu (via `_buildTower`) and
  /// [AiSkirmishControllerComponent], so both sides are bound by identical
  /// cost, prerequisite, per-type limit and reachability rules. Returns the
  /// built tower, or null if the build was rejected.
  TowerComponent? buildStructure(Team owner, UnitType type, Vector2 point) {
    final grid = terrainMap.grid;
    final cell = grid.worldToCell(point);
    if (!_isBuildableCell(cell)) return null;
    if (!canBuildTower(type, owner: owner)) return null;

    final blueprint = blueprintFor(type);
    if (goldFor(owner) < blueprint.cost) return null;

    // Provisionally occupy the cell and make sure the spawn-to-base
    // corridor stays open before actually charging gold - never allow a
    // fully sealed maze, regardless of which side is building.
    final spawnCells = terrainMap.spawnPoints
        .map((sp) => grid.worldToCell(Vector2(sp.x, sp.y)))
        .toSet();
    final baseCell = grid.worldToCell(
      Vector2(terrainMap.basePoint.x, terrainMap.basePoint.y),
    );
    grid.setTowerOccupied(cell.x, cell.y, true);
    if (!spawnCells.every((sc) => grid.isReachable(sc, baseCell))) {
      grid.setTowerOccupied(cell.x, cell.y, false);
      return null;
    }
    if (!spendGoldFor(owner, blueprint.cost)) {
      grid.setTowerOccupied(cell.x, cell.y, false);
      return null;
    }

    final tower = createTower(
      type,
      grid.cellCenter(cell),
      grid.cellSize,
      blueprint,
      owner: owner,
    );
    world.spawnTower(tower);
    if (type == BuildingType.techLab) _hasTechLabByTeam[owner.id] = true;
    if (type == BuildingType.commandPost) {
      _hasCommandPostByTeam[owner.id] = true;
    }
    return tower;
  }

  /// Builds a [TowerComponent] of [type] - shared by the player's own build
  /// menu and [AiSkirmishControllerComponent]. Ownership defaults to the
  /// human player, matching every call site before skirmish mode existed.
  TowerComponent createTower(
    UnitType type,
    Vector2 position,
    double cellSize,
    UnitBlueprint blueprint, {
    Team? owner,
  }) {
    final tower = switch (type) {
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
      BuildingType.goldMine => GoldMineComponent(
        position: position,
        cellSize: cellSize,
        blueprint: blueprint,
      ),
      _ => throw ArgumentError('Unknown unit type: $type'),
    };
    tower.owner = owner ?? playerTeam;
    return tower;
  }

  /// The opposing side's destructible home base, as an [Attackable] a
  /// [team] unit's weapon can engage - null outside skirmish mode, or once
  /// that base is already gone.
  Attackable? enemyHomeBaseFor(Team team) {
    if (aiTeam == null) return null;
    if (team.id == playerTeam.id) {
      final base = world.aiHomeBase;
      return (base != null && base.isMounted && !base.destroyed) ? base : null;
    }
    if (team.id == aiTeam!.id) {
      final base = world.playerHomeBase;
      return (base != null && base.isMounted && !base.destroyed) ? base : null;
    }
    return null;
  }

  /// Called whenever a Command Post is destroyed or sold - any Artillery
  /// Bunker built beyond what the remaining Command Posts can still support
  /// is torn down too (most-recently-built first, per owner independently),
  /// rather than left orphaned above the new cap.
  void enforceSupportedTowerLimits() {
    final bunkersByOwner = <int, List<TowerComponent>>{};
    for (final tower in world.activeTowers) {
      if (tower.blueprint.type != TowerType.artilleryBunker) continue;
      bunkersByOwner.putIfAbsent(tower.owner.id, () => []).add(tower);
    }
    for (final bunkers in bunkersByOwner.values) {
      final limit =
          buildLimitFor(TowerType.artilleryBunker, owner: bunkers.first.owner) ??
          0;
      final excess = bunkers.length - limit;
      for (var i = 0; i < excess; i++) {
        bunkers[bunkers.length - 1 - i].destroyBySupportLoss();
      }
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
      // The AI's own towers aren't the player's to inspect/repair/sell -
      // just cancel any in-progress placement instead of selecting them.
      if (tappedTower.owner.id != playerTeam.id) {
        pendingPlacement.value = null;
        return;
      }
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
    _setupSkirmishState();
    gameState.reset(startingGold: _resolvedStartingGold);
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    await camera.viewport.add(MinimapComponent());
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
    terrainMap = terrainRepository.loadTerrain(scene: scene);
    _setupSkirmishState();
    gameState.reset(startingGold: _resolvedStartingGold);
    world.activeUnits.clear();
    world.activeTowers.clear();
    for (final child in world.children.toList()) {
      if (child is! TerrainComponent) child.removeFromParent();
    }
    world.add(TerrainComponent(terrainMap: terrainMap));
    final skirmish = scene.mode == GameMode.skirmish;
    if (!skirmish) {
      world.add(WaveDirectorComponent());
    }
    world.add(
      CloudLayerComponent(
        arenaSize: Vector2(terrainMap.arenaWidth, terrainMap.arenaHeight),
      ),
    );
    world.playerHomeBase = HomeBaseComponent(
      position: Vector2(terrainMap.basePoint.x, terrainMap.basePoint.y),
      owner: playerTeam,
    );
    world.add(world.playerHomeBase!);
    if (skirmish) {
      final secondary = terrainMap.secondaryBasePoint;
      world.aiHomeBase = secondary == null
          ? null
          : AiHomeBaseComponent(position: Vector2(secondary.x, secondary.y));
      if (world.aiHomeBase != null) world.add(world.aiHomeBase!);
      world.add(AiSkirmishControllerComponent());
    } else {
      world.aiHomeBase = null;
    }
    world.add(GhostPlacementComponent());
    for (final point in terrainMap.resourceNodePoints) {
      world.add(ResourceNodeComponent(position: Vector2(point.x, point.y)));
    }
    enemyFocusHint = FocusHint.nearestTower;
    commanderNote.value = '';
    selectedTowerType.value = null;
    selectedTower.value = null;
    pendingPlacement.value = null;
    _hasTechLabByTeam.clear();
    _hasCommandPostByTeam.clear();
    world.cameraPosition = Vector2.zero();
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

  /// How many of [type] [owner] (defaults to the human player) currently
  /// has standing on the battlefield.
  int towerCountFor(UnitType type, {Team? owner}) {
    final builder = owner ?? playerTeam;
    return world.activeTowers
        .where((t) => t.blueprint.type == type && t.owner.id == builder.id)
        .length;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shakeEventWindow > 0) {
      _shakeEventWindow -= dt;
      if (_shakeEventWindow <= 0) _shakeEventCount = 0;
    }
    var shakeOffset = Vector2.zero();
    if (_shakeDuration > 0) {
      _shakeDuration = (_shakeDuration - dt).clamp(0.0, _shakeMaxDuration);
      if (_shakeDuration <= 0) {
        _shakePower = 0;
      } else {
        final falloff = _shakeDuration / _shakeMaxDuration;
        shakeOffset =
            Vector2(
              _shakeRandom.nextDouble() * 2 - 1,
              _shakeRandom.nextDouble() * 2 - 1,
            ) *
            (_shakePower * falloff);
      }
    }
    // Single writer for the viewfinder position - the free-scroll pan (see
    // `GameWorld._panCamera`) plus this frame's shake jitter on top, so the
    // two effects never fight over `camera.viewfinder.position`.
    camera.viewfinder.position = world.cameraPosition + shakeOffset;
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
    final tower = buildStructure(playerTeam, type, point);
    if (tower == null) return;
    audioRepository.play(SfxType.buildPlace, volume: 0.7);
    selectedTowerType.value = null;
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

  /// Sets/clears [aiTeam]/[aiEconomy] for the current [scene] - called from
  /// both [onLoad] and [restart] so a rematch re-derives the same skirmish
  /// state instead of carrying over a stale one.
  void _setupSkirmishState() {
    if (scene.mode == GameMode.skirmish) {
      aiTeam = Team.aiOpponent;
      aiEconomy = AiEconomy(
        gold: _resolvedStartingGold,
        health: GameConfig.startingHealth,
        maxHealth: GameConfig.startingHealth,
      );
    } else {
      aiTeam = null;
      aiEconomy = null;
    }
  }

  /// Starting gold for this match - the scene's own override if set,
  /// otherwise the mode-appropriate default (a skirmish base-building war
  /// needs far more up-front capital than the drip-fed wave-defense mode).
  /// Shared by both the player's `gameState` and the AI's `aiEconomy`.
  int get _resolvedStartingGold =>
      scene.startingGold ??
      (scene.mode == GameMode.skirmish
          ? GameConfig.startingSkirmishGold
          : GameConfig.startingGold);

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
