import 'package:boomspire/features/game_core/domain/models/game_scene.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/game_core/domain/repos/scene_cache_repository.dart';
import 'package:boomspire/features/game_core/domain/repos/scene_repository.dart';
import 'package:boomspire/features/game_core/impl/scene_sync_service.dart';
import 'package:boomspire/features/terrain/domain/models/biome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sceneNeedsUpdate', () {
    test('true when incoming version is higher', () {
      expect(
        sceneNeedsUpdate(cached: _scene('a', 1), incoming: _scene('a', 2)),
        isTrue,
      );
    });

    test('false when incoming version is equal or lower', () {
      expect(
        sceneNeedsUpdate(cached: _scene('a', 2), incoming: _scene('a', 2)),
        isFalse,
      );
      expect(
        sceneNeedsUpdate(cached: _scene('a', 2), incoming: _scene('a', 1)),
        isFalse,
      );
    });
  });

  group('SceneSyncService.resolveScenes', () {
    test('keeps seed data when remote fetch fails', () async {
      final service = SceneSyncService(
        _FakeRemoteRepo(() => throw StateError('offline')),
        _FakeCacheRepo(),
      );

      final scenes = await service.resolveScenes([_scene('a', 1)]);

      expect(scenes.single.version, 1);
    });

    test('overlays a cached scene with a higher version than seed', () async {
      final service = SceneSyncService(
        _FakeRemoteRepo(() => throw StateError('offline')),
        _FakeCacheRepo([_scene('a', 5)]),
      );

      final scenes = await service.resolveScenes([_scene('a', 1)]);

      expect(scenes.single.version, 5);
    });

    test(
      'overlays with a newer remote scene and persists it to cache',
      () async {
        final cache = _FakeCacheRepo();
        final service = SceneSyncService(
          _FakeRemoteRepo(() => [_scene('a', 9)]),
          cache,
        );

        final scenes = await service.resolveScenes([_scene('a', 1)]);

        expect(scenes.single.version, 9);
        expect(cache.stored?.single.version, 9);
      },
    );
  });

  group('GameScenes.applyOverrides', () {
    tearDown(GameScenes.resetOverridesForTest);

    test('replaces a matching built-in wave-defense scene by id', () {
      final replacement = GameScene(
        id: 'green-line',
        name: 'Green Line Redux',
        briefing: 'Reworked.',
        biome: Biome.grassPlains,
        waveCount: 12,
        version: 2,
      );

      GameScenes.applyOverrides([replacement]);

      expect(
        GameScenes.all.firstWhere((s) => s.id == 'green-line').waveCount,
        12,
      );
    });

    test('appends a brand new scene without dropping the others', () {
      final extra = GameScene(
        id: 'brand-new',
        name: 'Brand New',
        briefing: 'A new map from the server.',
        biome: Biome.grassPlains,
      );

      GameScenes.applyOverrides([extra]);

      expect(GameScenes.all.map((s) => s.id), contains('brand-new'));
      expect(GameScenes.all.map((s) => s.id), contains('green-line'));
    });

    test('splits overrides into all/skirmishes by mode', () {
      final skirmishOverride = GameScene(
        id: 'twin-outposts',
        name: 'Twin Outposts Redux',
        briefing: 'Reworked.',
        biome: Biome.grassPlains,
        mode: GameMode.skirmish,
        version: 2,
      );

      GameScenes.applyOverrides([skirmishOverride]);

      expect(
        GameScenes.skirmishes.firstWhere((s) => s.id == 'twin-outposts').name,
        'Twin Outposts Redux',
      );
      expect(GameScenes.all.map((s) => s.id), isNot(contains('twin-outposts')));
    });
  });
}

GameScene _scene(String id, int version) => GameScene(
  id: id,
  name: 'Scene $id',
  briefing: 'Briefing.',
  biome: Biome.grassPlains,
  version: version,
);

class _FakeCacheRepo implements SceneCacheRepository {
  List<GameScene>? stored;
  _FakeCacheRepo([this.stored]);

  @override
  Future<List<GameScene>?> loadCached() async => stored;

  @override
  Future<void> save(List<GameScene> scenes) async {
    stored = scenes;
  }
}

class _FakeRemoteRepo implements SceneRepository {
  final List<GameScene> Function() manifest;
  _FakeRemoteRepo(this.manifest);

  @override
  Future<List<GameScene>> fetchManifest() async => manifest();
}
