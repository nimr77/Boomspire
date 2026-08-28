import '../models/game_scene.dart';

/// Persists the last-synced scene manifest on-device (via ToStore, see
/// `LocalSceneCacheRepositoryImpl`) so the game doesn't need a live server
/// round-trip on every launch - only when something's newer.
abstract class SceneCacheRepository {
  /// `null` if nothing has ever been cached (first-ever launch before any
  /// successful sync).
  Future<List<GameScene>?> loadCached();

  Future<void> save(List<GameScene> scenes);
}
