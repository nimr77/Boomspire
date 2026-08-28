import '../domain/models/game_scene.dart';
import '../domain/repos/scene_cache_repository.dart';
import '../domain/repos/scene_repository.dart';

/// Resolves the scene/map list `GameScenes.applyOverrides` should layer on
/// top of the built-in defaults: the on-device cache overlaid with whatever
/// a best-effort live server fetch returns.
///
/// A failed/unreachable server fetch is not an error here - it just means
/// "nothing newer available right now", identical in spirit to
/// `GameContentSyncService`/`AiDirectorRepositoryImpl`'s fallback behavior.
class SceneSyncService {
  final SceneRepository _remote;
  final SceneCacheRepository _cache;

  SceneSyncService(this._remote, this._cache);

  Future<List<GameScene>> resolveScenes(List<GameScene> seed) async {
    final cached = await _cache.loadCached();
    var scenes = _merge(seed, cached ?? const []);

    try {
      final remote = await _remote.fetchManifest();
      final merged = _merge(scenes, remote);
      if (!_sameVersions(scenes, merged)) {
        await _cache.save(merged);
      }
      scenes = merged;
    } catch (_) {
      // Offline / proxy down - keep whatever seed+cache already produced.
    }

    return scenes;
  }

  /// For every id present in either list, keeps whichever scene has the
  /// higher [GameScene.version] (ties keep [base]).
  List<GameScene> _merge(List<GameScene> base, List<GameScene> incoming) {
    final byId = {for (final s in base) s.id: s};
    for (final candidate in incoming) {
      final current = byId[candidate.id];
      if (current == null ||
          sceneNeedsUpdate(cached: current, incoming: candidate)) {
        byId[candidate.id] = candidate;
      }
    }
    return byId.values.toList(growable: false);
  }

  bool _sameVersions(List<GameScene> a, List<GameScene> b) {
    if (a.length != b.length) return false;
    final versionsA = {for (final s in a) s.id: s.version};
    for (final s in b) {
      if (versionsA[s.id] != s.version) return false;
    }
    return true;
  }
}
