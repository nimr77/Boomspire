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
  static const empty = ProgressSnapshot();

  const factory ProgressSnapshot({
    @Default(<String>{}) Set<String> completedSceneIds,
    @Default(<String, int>{}) Map<String, int> bestWaveByScene,
    @Default(0) int totalScore,
  }) = _ProgressSnapshot;

  factory ProgressSnapshot.fromJson(Map<String, dynamic> json) =>
      _$ProgressSnapshotFromJson(json);

  const ProgressSnapshot._();

  int bestWaveFor(String sceneId) => bestWaveByScene[sceneId] ?? 0;

  bool isCompleted(String sceneId) => completedSceneIds.contains(sceneId);

  ProgressSnapshot withResult({
    required String sceneId,
    required int waveReached,
    required bool completed,
    int score = 0,
  }) {
    final bestSoFar = bestWaveFor(sceneId);
    return copyWith(
      completedSceneIds: {...completedSceneIds, if (completed) sceneId},
      bestWaveByScene: {
        ...bestWaveByScene,
        sceneId: waveReached > bestSoFar ? waveReached : bestSoFar,
      },
      totalScore: totalScore + score,
    );
  }
}
