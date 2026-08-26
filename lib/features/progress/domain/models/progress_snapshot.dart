import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_snapshot.freezed.dart';
part 'progress_snapshot.g.dart';

/// A player's saved campaign progress: which scenes have been completed at
/// least once, and the best (highest) wave reached per scene so far.
///
/// Purely a plain data holder - kept storage-agnostic so the same shape can
/// be persisted locally (see `LocalProgressRepositoryImpl`) or, later, to a
/// remote backend such as Firebase, without changing any call site.
@freezed
abstract class ProgressSnapshot with _$ProgressSnapshot {
  const ProgressSnapshot._();

  const factory ProgressSnapshot({
    @Default(<String>{}) Set<String> completedSceneIds,
    @Default(<String, int>{}) Map<String, int> bestWaveByScene,
  }) = _ProgressSnapshot;

  factory ProgressSnapshot.fromJson(Map<String, dynamic> json) =>
      _$ProgressSnapshotFromJson(json);

  static const empty = ProgressSnapshot();

  bool isCompleted(String sceneId) => completedSceneIds.contains(sceneId);

  int bestWaveFor(String sceneId) => bestWaveByScene[sceneId] ?? 0;

  ProgressSnapshot withResult({
    required String sceneId,
    required int waveReached,
    required bool completed,
  }) {
    final bestSoFar = bestWaveFor(sceneId);
    return copyWith(
      completedSceneIds: {...completedSceneIds, if (completed) sceneId},
      bestWaveByScene: {
        ...bestWaveByScene,
        sceneId: waveReached > bestSoFar ? waveReached : bestSoFar,
      },
    );
  }
}
