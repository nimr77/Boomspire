// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MapDraft _$MapDraftFromJson(Map<String, dynamic> json) => _MapDraft(
  id: json['id'] as String,
  name: json['name'] as String,
  biome:
      $enumDecodeNullable(_$BiomeEnumMap, json['biome']) ?? Biome.grassPlains,
  mode:
      $enumDecodeNullable(_$GameModeEnumMap, json['mode']) ??
      GameMode.waveDefense,
  arenaWidth: (json['arenaWidth'] as num?)?.toDouble() ?? 1280.0,
  arenaHeight: (json['arenaHeight'] as num?)?.toDouble() ?? 720.0,
  paintedCells:
      (json['paintedCells'] as List<dynamic>?)
          ?.map((e) => PaintedCell.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  treeCells:
      (json['treeCells'] as List<dynamic>?)
          ?.map((e) => TreeCell.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  waterPaths:
      (json['waterPaths'] as List<dynamic>?)
          ?.map((e) => WaterPath.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  homeSites:
      (json['homeSites'] as List<dynamic>?)
          ?.map((e) => EditorPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  environment: json['environment'] == null
      ? const EnvironmentSettings()
      : EnvironmentSettings.fromJson(
          json['environment'] as Map<String, dynamic>,
        ),
  startingGold: (json['startingGold'] as num?)?.toInt() ?? 3000,
  waveCount: (json['waveCount'] as num?)?.toInt() ?? 10,
  waveLoadouts:
      (json['waveLoadouts'] as List<dynamic>?)
          ?.map((e) => WaveLoadout.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$MapDraftToJson(_MapDraft instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'biome': _$BiomeEnumMap[instance.biome]!,
  'mode': _$GameModeEnumMap[instance.mode]!,
  'arenaWidth': instance.arenaWidth,
  'arenaHeight': instance.arenaHeight,
  'paintedCells': instance.paintedCells.map((e) => e.toJson()).toList(),
  'treeCells': instance.treeCells.map((e) => e.toJson()).toList(),
  'waterPaths': instance.waterPaths.map((e) => e.toJson()).toList(),
  'homeSites': instance.homeSites.map((e) => e.toJson()).toList(),
  'environment': instance.environment.toJson(),
  'startingGold': instance.startingGold,
  'waveCount': instance.waveCount,
  'waveLoadouts': instance.waveLoadouts.map((e) => e.toJson()).toList(),
};

const _$BiomeEnumMap = {
  Biome.grassPlains: 'grassPlains',
  Biome.snowTundra: 'snowTundra',
  Biome.desertDunes: 'desertDunes',
  Biome.mountainForest: 'mountainForest',
  Biome.cityRuins: 'cityRuins',
  Biome.savanna: 'savanna',
  Biome.frozenPeaks: 'frozenPeaks',
  Biome.sea: 'sea',
  Biome.snowyGrassland: 'snowyGrassland',
};

const _$GameModeEnumMap = {
  GameMode.waveDefense: 'waveDefense',
  GameMode.skirmish: 'skirmish',
};
