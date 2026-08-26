// Automated gameplay smoke tests: exercise the exact tap -> build pipeline
// that's otherwise only reachable via manual play, so regressions in tower
// placement/economy/pathfinding are caught by `flutter test` instead of
// needing a human (or flaky browser automation) to click through the game.
//
// These load the game directly (onGameResize/load/mount/update) instead of
// pumping a full widget tree, since that's much faster and all we need is
// the component tree mounted so tap handling and pathfinding work.
import 'dart:math';

import 'package:circuit_defense/features/ai_director/impl/ai_director_repository_impl.dart';
import 'package:circuit_defense/features/audio/domain/models/sfx_type.dart';
import 'package:circuit_defense/features/audio/domain/repos/audio_repository.dart';
import 'package:circuit_defense/features/enemies/impl/enemy_repository_impl.dart';
import 'package:circuit_defense/features/game_core/impl/game_state_repository_impl.dart';
import 'package:circuit_defense/features/game_core/presentation/circuit_defense_game.dart';
import 'package:circuit_defense/features/terrain/domain/models/biome.dart';
import 'package:circuit_defense/features/terrain/impl/terrain_repository_impl.dart';
import 'package:circuit_defense/features/towers/domain/models/tower_type.dart';
import 'package:circuit_defense/features/towers/impl/tower_repository_impl.dart';
import 'package:circuit_defense/features/waves/impl/wave_repository_impl.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

/// No-op audio - the real impl needs real audio plugins that aren't
/// available under `flutter test`.
class _FakeAudioRepository implements AudioRepository {
  @override
  void play(SfxType type, {double volume = 1}) {}

  @override
  Future<void> preload() async {}
}

CircuitDefenseGame _newGame(Biome biome) => CircuitDefenseGame(
  terrainRepository: TerrainRepositoryImpl(),
  towerRepository: TowerRepositoryImpl(),
  enemyRepository: EnemyRepositoryImpl(),
  waveRepository: WaveRepositoryImpl(),
  audioRepository: _FakeAudioRepository(),
  gameState: GameStateRepositoryImpl(),
  aiDirector: AiDirectorRepositoryImpl(),
  biome: biome,
);

/// Boots a game without pumping a full Flutter widget tree (much faster).
Future<CircuitDefenseGame> _bootGame(Biome biome) async {
  final game = _newGame(biome);
  game.onGameResize(Vector2(1280, 720));
  // ignore: invalid_use_of_internal_member
  await game.load();
  // ignore: invalid_use_of_internal_member
  game.mount();
  game.update(0);
  return game;
}

/// Finds an open, buildable cell (not blocked, not spawn/base) so tests
/// don't depend on any particular random terrain layout.
Point<int> _findOpenCell(CircuitDefenseGame game) {
  final grid = game.terrainMap.grid;
  final spawnCell = grid.worldToCell(
    Vector2(game.terrainMap.spawnPoint.x, game.terrainMap.spawnPoint.y),
  );
  final baseCell = grid.worldToCell(
    Vector2(game.terrainMap.basePoint.x, game.terrainMap.basePoint.y),
  );
  for (var row = 0; row < grid.rows; row++) {
    for (var col = 0; col < grid.cols; col++) {
      final cell = Point(col, row);
      if (!grid.isBlocked(col, row) && cell != spawnCell && cell != baseCell) {
        return cell;
      }
    }
  }
  throw StateError('no open cell found');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('build pipeline', () {
    for (final biome in Biome.values) {
      test('selecting + tapping an open cell places a tower (${biome.name})', () async {
        final game = await _bootGame(biome);
        final openCell = _findOpenCell(game);
        final startingGold = game.gameState.gold;

        game.selectTowerType(TowerType.machineGun);
        game.handleArenaTap(game.terrainMap.grid.cellCenter(openCell));

        expect(
          game.gameState.gold,
          lessThan(startingGold),
          reason: 'gold should be spent after a successful build',
        );
        expect(game.world.activeTowers, hasLength(1));
      });
    }

    test('tapping a blocked (mountain/river) cell does not spend gold', () async {
      final game = await _bootGame(Biome.grassPlains);
      final grid = game.terrainMap.grid;
      Point<int>? blockedCell;
      outer:
      for (var row = 0; row < grid.rows; row++) {
        for (var col = 0; col < grid.cols; col++) {
          if (grid.isBlocked(col, row)) {
            blockedCell = Point(col, row);
            break outer;
          }
        }
      }
      expect(blockedCell, isNotNull);

      final startingGold = game.gameState.gold;
      game.selectTowerType(TowerType.machineGun);
      game.handleArenaTap(grid.cellCenter(blockedCell!));

      expect(game.gameState.gold, startingGold);
      expect(game.world.activeTowers, isEmpty);
    });
  });

  test('every biome generates a terrain where spawn can reach base', () {
    for (final biome in Biome.values) {
      final terrain = TerrainRepositoryImpl().loadTerrain(biome: biome);
      final grid = terrain.grid;
      final spawnCell = grid.worldToCell(
        Vector2(terrain.spawnPoint.x, terrain.spawnPoint.y),
      );
      final baseCell = grid.worldToCell(
        Vector2(terrain.basePoint.x, terrain.basePoint.y),
      );
      expect(
        grid.isReachable(spawnCell, baseCell),
        isTrue,
        reason: '${biome.name} terrain must not fully wall off spawn from base',
      );
    }
  });
}
