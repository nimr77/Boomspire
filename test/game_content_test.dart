import 'package:boomspire/features/game_content/domain/models/asset_source.dart';
import 'package:boomspire/features/game_content/domain/models/build_requirement.dart';
import 'package:boomspire/features/game_content/domain/models/game_object_category.dart';
import 'package:boomspire/features/game_content/domain/models/game_object_definition.dart';
import 'package:boomspire/features/game_content/domain/models/sound_ref.dart';
import 'package:boomspire/features/game_content/domain/repos/game_content_cache_repository.dart';
import 'package:boomspire/features/game_content/domain/repos/game_content_repository.dart';
import 'package:boomspire/features/game_content/impl/game_content_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('needsUpdate', () {
    test('true when incoming version is higher', () {
      expect(needsUpdate(cached: _def('a', 1), incoming: _def('a', 2)), isTrue);
    });

    test('false when incoming version is equal or lower', () {
      expect(
        needsUpdate(cached: _def('a', 2), incoming: _def('a', 2)),
        isFalse,
      );
      expect(
        needsUpdate(cached: _def('a', 2), incoming: _def('a', 1)),
        isFalse,
      );
    });
  });

  group('GameObjectDefinition JSON round-trip', () {
    test('preserves fields including requirements/asset/sound', () {
      final original = _def(
        'building.techLab',
        3,
        requirements: const [ScoreRequirement(500), MaxCountRequirement(1)],
      );

      final roundTripped = GameObjectDefinition.fromJson(original.toJson());

      expect(roundTripped, original);
      expect(roundTripped.requirements, hasLength(2));
      expect(roundTripped.requirements[0], isA<ScoreRequirement>());
      expect((roundTripped.requirements[0] as ScoreRequirement).minScore, 500);
      expect(roundTripped.requirements[1], isA<MaxCountRequirement>());
    });
  });

  group('GameContentSyncService.resolveCatalog', () {
    test('keeps seed data when remote fetch fails', () async {
      final service = GameContentSyncService(
        _FakeRemoteRepo(() => throw StateError('offline')),
        _FakeCacheRepo(),
      );

      final catalog = await service.resolveCatalog([_def('a', 1)]);

      expect(catalog, [_def('a', 1)]);
    });

    test(
      'overlays a cached definition with a higher version than seed',
      () async {
        final service = GameContentSyncService(
          _FakeRemoteRepo(() => throw StateError('offline')),
          _FakeCacheRepo([_def('a', 5)]),
        );

        final catalog = await service.resolveCatalog([_def('a', 1)]);

        expect(catalog.single.version, 5);
      },
    );

    test(
      'overlays with a newer remote definition and persists it to cache',
      () async {
        final cache = _FakeCacheRepo();
        final service = GameContentSyncService(
          _FakeRemoteRepo(() => [_def('a', 9)]),
          cache,
        );

        final catalog = await service.resolveCatalog([_def('a', 1)]);

        expect(catalog.single.version, 9);
        expect(cache.stored?.single.version, 9);
      },
    );
  });
}

GameObjectDefinition _def(
  String id,
  int version, {
  List<BuildRequirement> requirements = const [],
}) {
  return GameObjectDefinition(
    id: id,
    version: version,
    category: GameObjectCategory.tower,
    damage: 10,
    requirements: requirements,
    modelView: const AssetSource(path: 'tower_machineGun'),
    sound: const SoundRef(),
  );
}

class _FakeCacheRepo implements GameContentCacheRepository {
  List<GameObjectDefinition>? stored;
  _FakeCacheRepo([this.stored]);

  @override
  Future<List<GameObjectDefinition>?> loadCached() async => stored;

  @override
  Future<void> save(List<GameObjectDefinition> definitions) async {
    stored = definitions;
  }
}

class _FakeRemoteRepo implements GameContentRepository {
  final List<GameObjectDefinition> Function() manifest;
  _FakeRemoteRepo(this.manifest);

  @override
  Future<List<GameObjectDefinition>> fetchManifest() async => manifest();
}
