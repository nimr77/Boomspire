import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../../audio/domain/models/sfx_type.dart';
import '../../audio/domain/repos/audio_repository.dart';
import '../../enemies/domain/repos/enemy_repository.dart';
import '../../terrain/domain/models/build_slot.dart';
import '../../terrain/domain/models/terrain_map.dart';
import '../../terrain/domain/repos/terrain_repository.dart';
import '../../terrain/presentation/terrain_component.dart';
import '../../towers/domain/models/tower_blueprint.dart';
import '../../towers/domain/models/tower_type.dart';
import '../../towers/domain/repos/tower_repository.dart';
import '../../towers/presentation/machine_gun_tower_component.dart';
import '../../towers/presentation/rocket_tower_component.dart';
import '../../towers/presentation/tower_component.dart';
import '../../waves/domain/repos/wave_repository.dart';
import '../../waves/presentation/wave_director_component.dart';
import '../domain/models/game_config.dart';
import '../domain/models/game_status.dart';
import '../domain/repos/game_state_repository.dart';
import 'game_world.dart';

/// Composition root: wires the domain repositories into a running Flame
/// game, owns the shared "build mode" selection, and mediates tower
/// placement taps coming from [GameWorld].
class CircuitDefenseGame extends FlameGame<GameWorld> {
  CircuitDefenseGame({
    required this.terrainRepository,
    required this.towerRepository,
    required this.enemyRepository,
    required this.waveRepository,
    required this.audioRepository,
    required this.gameState,
  }) : super(
         world: GameWorld(),
         camera: CameraComponent.withFixedResolution(
           width: GameConfig.arenaWidth,
           height: GameConfig.arenaHeight,
         ),
       );

  final TerrainRepository terrainRepository;
  final TowerRepository towerRepository;
  final EnemyRepository enemyRepository;
  final WaveRepository waveRepository;
  final AudioRepository audioRepository;
  final GameStateRepository gameState;

  late final TerrainMap terrainMap;
  final ValueNotifier<TowerType?> selectedTowerType = ValueNotifier(null);

  @override
  Color backgroundColor() => const Color(0xFF14181d);

  @override
  Future<void> onLoad() async {
    terrainMap = terrainRepository.loadTerrain();
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    await audioRepository.preload();
    await world.initialize();
  }

  void selectTowerType(TowerType? type) {
    selectedTowerType.value = selectedTowerType.value == type ? null : type;
  }

  void handleArenaTap(Vector2 point) {
    final type = selectedTowerType.value;
    if (type == null || gameState.status != GameStatus.playing) return;

    final slot = _findSlotNear(point);
    if (slot == null || slot.occupied) return;

    final blueprint = towerRepository.blueprintFor(type);
    if (!gameState.spendGold(blueprint.cost)) return;

    slot.occupied = true;
    world.spawnTower(_createTower(type, slot, blueprint));
    audioRepository.play(SfxType.buildPlace, volume: 0.7);
    selectedTowerType.value = null;
  }

  void restart() {
    gameState.reset();
    for (final slot in terrainMap.buildSlots) {
      slot.occupied = false;
    }
    world.activeEnemies.clear();
    world.activeTowers.clear();
    for (final child in world.children.toList()) {
      if (child is! TerrainComponent) child.removeFromParent();
    }
    world.add(WaveDirectorComponent());
    selectedTowerType.value = null;
  }

  BuildSlot? _findSlotNear(Vector2 point) {
    const tapRadius = 42.0;
    for (final slot in terrainMap.buildSlots) {
      final dx = slot.x - point.x;
      final dy = slot.y - point.y;
      if (dx * dx + dy * dy <= tapRadius * tapRadius) return slot;
    }
    return null;
  }

  TowerComponent _createTower(
    TowerType type,
    BuildSlot slot,
    TowerBlueprint blueprint,
  ) {
    return switch (type) {
      TowerType.machineGun => MachineGunTowerComponent(
        slot: slot,
        blueprint: blueprint,
      ),
      TowerType.rocket => RocketTowerComponent(slot: slot, blueprint: blueprint),
    };
  }
}
