// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wave_loadout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WaveLoadout _$WaveLoadoutFromJson(Map<String, dynamic> json) => _WaveLoadout(
  waveNumber: (json['waveNumber'] as num).toInt(),
  unitCounts:
      (json['unitCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
);

Map<String, dynamic> _$WaveLoadoutToJson(_WaveLoadout instance) =>
    <String, dynamic>{
      'waveNumber': instance.waveNumber,
      'unitCounts': instance.unitCounts,
    };
