// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProgressSnapshot _$ProgressSnapshotFromJson(Map<String, dynamic> json) =>
    _ProgressSnapshot(
      completedSceneIds:
          (json['completedSceneIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const <String>{},
      bestWaveByScene:
          (json['bestWaveByScene'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProgressSnapshotToJson(_ProgressSnapshot instance) =>
    <String, dynamic>{
      'completedSceneIds': instance.completedSceneIds.toList(),
      'bestWaveByScene': instance.bestWaveByScene,
      'totalScore': instance.totalScore,
    };
