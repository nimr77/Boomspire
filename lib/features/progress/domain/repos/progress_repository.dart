import '../models/progress_snapshot.dart';

/// Persists and loads the player's campaign progress.
///
/// Implementations are swappable: [ProgressSnapshot] is a plain value type,
/// so the same interface can be backed by on-device storage (the default,
/// for signed-out play) or a remote store such as Firebase for signed-in
/// users, without any call site needing to change.
abstract class ProgressRepository {
  Future<ProgressSnapshot> load();

  Future<void> recordRun({
    required String sceneId,
    required int waveReached,
    required bool completed,
  });
}
