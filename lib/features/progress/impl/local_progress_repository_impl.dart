import '../../../core/storage/app_database.dart';
import '../domain/models/progress_snapshot.dart';
import '../domain/repos/progress_repository.dart';

/// On-device progress storage via ToStore's key-value engine - used
/// whenever the player is not signed into a cloud account. Stored as a
/// single small JSON blob (via the freezed-generated `toJson`/`fromJson`)
/// under one key.
///
/// This is intentionally the *only* place that knows about the storage
/// mechanism; a future `FirebaseProgressRepositoryImpl` implementing the same
/// [ProgressRepository] interface can replace/wrap this once accounts exist,
/// without touching any UI code.
class LocalProgressRepositoryImpl implements ProgressRepository {
  static const _key = 'boomspire.progress.v1';

  @override
  Future<ProgressSnapshot> load() async {
    final db = await AppDatabase.instance;
    final raw = await db.getValue(_key);
    if (raw == null) return ProgressSnapshot.empty;
    try {
      return ProgressSnapshot.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (_) {
      // Corrupt/foreign data shouldn't crash the level-select screen.
      return ProgressSnapshot.empty;
    }
  }

  @override
  Future<void> recordRun({
    required String sceneId,
    required int waveReached,
    required bool completed,
    int score = 0,
  }) async {
    final current = await load();
    final updated = current.withResult(
      sceneId: sceneId,
      waveReached: waveReached,
      completed: completed,
      score: score,
    );
    final db = await AppDatabase.instance;
    await db.setValue(_key, updated.toJson());
  }
}
