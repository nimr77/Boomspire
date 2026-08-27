// Automated gameplay smoke tests: exercise the exact tap -> build pipeline
// that's otherwise only reachable via manual play, so regressions in tower
// placement/economy/pathfinding are caught by `flutter test` instead of
// needing a human (or flaky browser automation) to click through the game.
//
// These load the game directly (onGameResize/load/mount/update) instead of
// pumping a full widget tree, since that's much faster and all we need is
// the component tree mounted so tap handling and pathfinding work.
import 'dart:math';

import 'package:boomspire/features/ai_director/impl/ai_director_repository_impl.dart';
import 'package:boomspire/features/audio/domain/models/sfx_type.dart';
import 'package:boomspire/features/audio/domain/repos/audio_repository.dart';
import 'package:boomspire/features/enemies/impl/enemy_repository_impl.dart';
import 'package:boomspire/features/game_core/domain/models/game_scene.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/game_core/impl/game_state_repository_impl.dart';
import 'package:boomspire/features/game_core/presentation/boomspire_game.dart';
import 'package:boomspire/features/terrain/impl/terrain_repository_impl.dart';
import 'package:boomspire/features/towers/domain/models/tower_type.dart';
import 'package:boomspire/features/towers/impl/tower_repository_impl.dart';
import 'package:boomspire/features/waves/impl/wave_repository_impl.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('build pipeline', () {
    for (final scene in GameScenes.all) {
      test(
        'selecting + tapping an open cell places a tower (${scene.id})',
        () async {
          final game = await _bootGame(scene);
          final openCell = _findOpenCell(game);
          final startingGold = game.gameState.gold;

          game.selectTowerType(TowerType.machineGun);
          final cellCenter = game.terrainMap.grid.cellCenter(openCell);
          // First tap only previews the range/footprint; the same cell must
          // be tapped again to actually commit the build (see
          // BoomspireGame.pendingPlacement).
          game.handleArenaTap(cellCenter);
          expect(game.pendingPlacement.value, openCell);
          game.handleArenaTap(cellCenter);

          expect(
            game.gameState.gold,
            lessThan(startingGold),
            reason: 'gold should be spent after a successful build',
          );
          expect(game.world.activeTowers, hasLength(1));
        },
      );
    }

    test(
      'tapping a blocked (mountain/river) cell does not spend gold',
      () async {
        final game = await _bootGame(GameScenes.all.first);
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
      },
    );

    test(
      'single-use buildings (Tech Lab, Command Post) lock once built',
      () async {
        for (final type in [TowerType.techLab, TowerType.commandPost]) {
          final game = await _bootGame(GameScenes.all.first);
          final grid = game.terrainMap.grid;
          expect(game.buildBlockReason(type), isNull);
          game.gameState.addGold(1000);

          final cell = _findOpenCell(game);
          game.selectTowerType(type);
          game.handleArenaTap(grid.cellCenter(cell));
          game.handleArenaTap(grid.cellCenter(cell));

          expect(game.towerCountFor(type), 1);
          expect(
            game.buildBlockReason(type),
            'Max 1 built',
            reason:
                '$type should report a lock reason once its 1-build cap is hit',
          );
        }
      },
    );
  });

  test('every scene generates a terrain where every spawn can reach base', () {
    for (final scene in GameScenes.all) {
      final terrain = TerrainRepositoryImpl().loadTerrain(scene: scene);
      final grid = terrain.grid;
      final baseCell = grid.worldToCell(
        Vector2(terrain.basePoint.x, terrain.basePoint.y),
      );
      for (final spawnPoint in terrain.spawnPoints) {
        final spawnCell = grid.worldToCell(Vector2(spawnPoint.x, spawnPoint.y));
        expect(
          grid.isReachable(spawnCell, baseCell),
          isTrue,
          reason:
              '${scene.id} terrain must not fully wall off a spawn from base',
        );
      }
    }
  });
}

/// Boots a game without pumping a full Flutter widget tree (much faster).
Future<BoomspireGame> _bootGame(GameScene scene) async {
  final game = _newGame(scene);
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
Point<int> _findOpenCell(BoomspireGame game) {
  final grid = game.terrainMap.grid;
  final spawnCells = game.terrainMap.spawnPoints
      .map((sp) => grid.worldToCell(Vector2(sp.x, sp.y)))
      .toSet();
  final baseCell = grid.worldToCell(
    Vector2(game.terrainMap.basePoint.x, game.terrainMap.basePoint.y),
  );
  for (var row = 0; row < grid.rows; row++) {
    for (var col = 0; col < grid.cols; col++) {
      final cell = Point(col, row);
      if (!grid.isBlocked(col, row) &&
          !spawnCells.contains(cell) &&
          cell != baseCell) {
        return cell;
      }
    }
  }
  throw StateError('no open cell found');
}

BoomspireGame _newGame(GameScene scene) => BoomspireGame(
  terrainRepository: TerrainRepositoryImpl(),
  towerRepository: TowerRepositoryImpl(),
  enemyRepository: EnemyRepositoryImpl(),
  waveRepository: WaveRepositoryImpl(
    totalWaves: scene.waveCount,
    biome: scene.biome,
  ),
  audioRepository: _FakeAudioRepository(),
  gameState: GameStateRepositoryImpl(),
  aiDirector: AiDirectorRepositoryImpl(),
  scene: scene,
);

/// No-op audio - the real impl needs real audio plugins that aren't
/// available under `flutter test`.
class _FakeAudioRepository implements AudioRepository {
  @override
  void play(SfxType type, {double volume = 1}) {}

  @override
  Future<void> preload() async {}
}
