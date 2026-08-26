import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../../ai_director/domain/models/strategy_directive.dart';
import '../../ai_director/domain/repos/ai_director_repository.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../audio/domain/repos/audio_repository.dart';
import '../../enemies/domain/repos/enemy_repository.dart';
import '../../terrain/domain/models/biome.dart';
import '../../terrain/domain/models/terrain_map.dart';
import '../../terrain/domain/repos/terrain_repository.dart';
import '../../terrain/presentation/cloud_layer_component.dart';
import '../../terrain/presentation/terrain_component.dart';
import '../../towers/domain/models/tower_blueprint.dart';
import '../../towers/domain/models/tower_type.dart';
import '../../towers/domain/repos/tower_repository.dart';
import '../../towers/presentation/anti_air_tower_component.dart';
import '../../towers/presentation/cannon_tower_component.dart';
import '../../towers/presentation/machine_gun_tower_component.dart';
import '../../towers/presentation/rocket_tower_component.dart';
import '../../towers/presentation/tower_component.dart';
import '../../waves/domain/repos/wave_repository.dart';
import '../../waves/presentation/wave_director_component.dart';
import '../domain/models/game_config.dart';
import '../domain/models/game_status.dart';
import '../domain/repos/game_state_repository.dart';
import 'game_world.dart';
import 'home_base_component.dart';
import 'spawn_indicator_component.dart';

/// Composition root: wires the domain repositories into a running Flame
/// game, owns the shared "build mode" selection, and mediates tower
/// placement/repair taps coming from [GameWorld].
class CircuitDefenseGame extends FlameGame<GameWorld> {
  final TerrainRepository terrainRepository;

  final TowerRepository towerRepository;
  final EnemyRepository enemyRepository;
  final WaveRepository waveRepository;
  final AudioRepository audioRepository;
  final GameStateRepository gameState;
  final AiDirectorRepository aiDirector;
  final Biome biome;
  late TerrainMap terrainMap;

  final ValueNotifier<TowerType?> selectedTowerType = ValueNotifier(null);
  final ValueNotifier<String> commanderNote = ValueNotifier('');

  /// What the enemy AI director wants enemies to prioritize this wave.
  FocusHint enemyFocusHint = FocusHint.nearestTower;

  final Random _shakeRandom = Random();
  double _shakeDuration = 0;
  double _shakeMaxDuration = 0;
  double _shakePower = 0;

  CircuitDefenseGame({
    required this.terrainRepository,
    required this.towerRepository,
    required this.enemyRepository,
    required this.waveRepository,
    required this.audioRepository,
    required this.gameState,
    required this.aiDirector,
    required this.biome,
  }) : super(
         world: GameWorld(),
         camera: CameraComponent.withFixedResolution(
           width: GameConfig.arenaWidth,
           height: GameConfig.arenaHeight,
         ),
       );

  @override
  Color backgroundColor() => const Color(0xFF14181d);

  /// Routes an arena tap to either repairing a damaged tower under the tap,
  /// or - if a tower type is selected - building on an empty, reachable
  /// grid cell.
  void handleArenaTap(Vector2 point) {
    if (gameState.status != GameStatus.playing) return;

    final tappedTower = _towerAt(point);
    if (tappedTower != null) {
      _repairTower(tappedTower);
      return;
    }

    final type = selectedTowerType.value;
    if (type == null) return;
    _buildTower(type, point);
  }

  @override
  Future<void> onLoad() async {
    terrainMap = terrainRepository.loadTerrain(biome: biome);
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    await audioRepository.preload();
    await world.initialize();
  }

  @override
  void update(double dt) {
    super.update(dt);
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

  /// Nudges the camera briefly whenever something fires - stronger weapons
  /// and shots closer to the camera's focal point (the arena's center)
  /// shake harder, like a real camera would.
  void shakeCamera({required double power, required Vector2 origin}) {
    final focus = Vector2(GameConfig.arenaWidth / 2, GameConfig.arenaHeight / 2);
    final maxDistance = focus.length;
    final proximity = (1 - origin.distanceTo(focus) / maxDistance).clamp(
      0.2,
      1.0,
    );
    final effectivePower = (power * 0.18 * proximity).clamp(0.0, 14.0);
    if (effectivePower < _shakePower) return;
    _shakePower = effectivePower;
    _shakeMaxDuration = _shakeDuration = 0.1 + effectivePower * 0.01;
  }

  void restart() {
    gameState.reset();
    terrainMap = terrainRepository.loadTerrain(biome: biome);
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
      SpawnIndicatorComponent(
        position: Vector2(terrainMap.spawnPoint.x, terrainMap.spawnPoint.y - 34),
      ),
    );
    world.add(
      HomeBaseComponent(
        position: Vector2(terrainMap.basePoint.x, terrainMap.basePoint.y),
      ),
    );
    enemyFocusHint = FocusHint.nearestTower;
    commanderNote.value = '';
    selectedTowerType.value = null;
  }

  void selectTowerType(TowerType? type) {
    selectedTowerType.value = selectedTowerType.value == type ? null : type;
  }

  void _buildTower(TowerType type, Vector2 point) {
    final grid = terrainMap.grid;
    final cell = grid.worldToCell(point);
    if (grid.isBlocked(cell.x, cell.y)) return;

    final spawnCell = grid.worldToCell(
      Vector2(terrainMap.spawnPoint.x, terrainMap.spawnPoint.y),
    );
    final baseCell = grid.worldToCell(
      Vector2(terrainMap.basePoint.x, terrainMap.basePoint.y),
    );
    if (cell == spawnCell || cell == baseCell) return;

    final blueprint = towerRepository.blueprintFor(type);
    if (gameState.gold < blueprint.cost) return;

    // Provisionally occupy the cell and make sure ground enemies can still
    // reach the base before actually charging gold - never allow a fully
    // sealed maze.
    grid.setTowerOccupied(cell.x, cell.y, true);
    if (!grid.isReachable(spawnCell, baseCell)) {
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
    audioRepository.play(SfxType.buildPlace, volume: 0.7);
    selectedTowerType.value = null;
  }

  TowerComponent _createTower(
    TowerType type,
    Vector2 position,
    double cellSize,
    TowerBlueprint blueprint,
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
    };
  }

  void _repairTower(TowerComponent tower) {
    final cost = tower.repairCost;
    if (cost <= 0) return;
    if (!gameState.spendGold(cost)) return;
    tower.repair(tower.blueprint.maxHp);
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
