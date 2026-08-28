import '../../../core/storage/app_database.dart';
import '../domain/models/game_object_definition.dart';
import '../domain/repos/game_content_cache_repository.dart';

/// On-device game-content cache via ToStore's key-value engine - stores the
/// whole last-synced manifest as one JSON array blob under a single key,
/// exactly like `LocalProgressRepositoryImpl` stores its snapshot.
class LocalGameContentCacheRepositoryImpl implements GameContentCacheRepository {
  static const _key = 'boomspire.game_content.v1';

  @override
  Future<List<GameObjectDefinition>?> loadCached() async {
    final db = await AppDatabase.instance;
    final raw = await db.getValue(_key);
    if (raw == null) return null;
    try {
      return (raw as List)
          .map((e) => GameObjectDefinition.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      // Corrupt/foreign cache shouldn't crash catalog hydration - treat it
      // the same as "never synced".
      return null;
    }
  }

  @override
  Future<void> save(List<GameObjectDefinition> definitions) async {
    final db = await AppDatabase.instance;
    await db.setValue(_key, definitions.map((d) => d.toJson()).toList());
  }
}
