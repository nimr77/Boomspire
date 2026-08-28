import '../domain/models/game_object_definition.dart';
import '../domain/repos/game_content_cache_repository.dart';
import '../domain/repos/game_content_repository.dart';

/// Resolves the catalog every tower/building/unit repository should read
/// from: the bundled seed manifest (so the game has full content offline
/// and in tests, with zero network), overlaid with whatever's newer in the
/// on-device cache, then overlaid again with whatever's newer from a
/// best-effort live server fetch.
///
/// A failed/unreachable server fetch is not an error here - it just means
/// "nothing newer available right now", identical in spirit to how
/// `AiDirectorRepositoryImpl` falls back to a heuristic when its proxy call
/// fails.
class GameContentSyncService {
  final GameContentRepository _remote;
  final GameContentCacheRepository _cache;

  GameContentSyncService(this._remote, this._cache);

  Future<List<GameObjectDefinition>> resolveCatalog(
    List<GameObjectDefinition> seed,
  ) async {
    final cached = await _cache.loadCached();
    var catalog = _merge(seed, cached ?? const []);

    try {
      final remote = await _remote.fetchManifest();
      final merged = _merge(catalog, remote);
      if (!_sameVersions(catalog, merged)) {
        await _cache.save(merged);
      }
      catalog = merged;
    } catch (_) {
      // Offline / proxy down - keep whatever seed+cache already produced.
    }

    return catalog;
  }

  /// For every id present in either list, keeps whichever definition has
  /// the higher [GameObjectDefinition.version] (ties keep [base]).
  List<GameObjectDefinition> _merge(
    List<GameObjectDefinition> base,
    List<GameObjectDefinition> incoming,
  ) {
    final byId = {for (final d in base) d.id: d};
    for (final candidate in incoming) {
      final current = byId[candidate.id];
      if (current == null || needsUpdate(cached: current, incoming: candidate)) {
        byId[candidate.id] = candidate;
      }
    }
    return byId.values.toList(growable: false);
  }

  bool _sameVersions(List<GameObjectDefinition> a, List<GameObjectDefinition> b) {
    if (a.length != b.length) return false;
    final versionsA = {for (final d in a) d.id: d.version};
    for (final d in b) {
      if (versionsA[d.id] != d.version) return false;
    }
    return true;
  }
}
