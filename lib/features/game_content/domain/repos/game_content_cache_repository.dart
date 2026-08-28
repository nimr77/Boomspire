import '../models/game_object_definition.dart';

/// Persists the last-synced game-content manifest on-device (via ToStore,
/// see `LocalGameContentCacheRepositoryImpl`) so the game doesn't need a
/// live server round-trip on every launch - only when something's newer.
abstract class GameContentCacheRepository {
  /// `null` if nothing has ever been cached (first-ever launch before any
  /// successful sync).
  Future<List<GameObjectDefinition>?> loadCached();

  Future<void> save(List<GameObjectDefinition> definitions);
}
