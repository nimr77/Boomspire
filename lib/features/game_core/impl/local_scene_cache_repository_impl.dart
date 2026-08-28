import '../../../core/storage/app_database.dart';
import '../domain/models/game_scene.dart';
import '../domain/repos/scene_cache_repository.dart';

/// On-device scene-manifest cache via ToStore's key-value engine - stores
/// the whole last-synced list as one JSON array blob under a single key,
/// same approach as `LocalGameContentCacheRepositoryImpl`.
class LocalSceneCacheRepositoryImpl implements SceneCacheRepository {
  static const _key = 'boomspire.scenes.v1';

  @override
  Future<List<GameScene>?> loadCached() async {
    final db = await AppDatabase.instance;
    final raw = await db.getValue(_key);
    if (raw == null) return null;
    try {
      return (raw as List)
          .map((e) => GameScene.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      // Corrupt/foreign cache shouldn't crash scene hydration - treat it
      // the same as "never synced".
      return null;
    }
  }

  @override
  Future<void> save(List<GameScene> scenes) async {
    final db = await AppDatabase.instance;
    await db.setValue(_key, scenes.map((s) => s.toJson()).toList());
  }
}
