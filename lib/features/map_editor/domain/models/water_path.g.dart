// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_path.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WaterPath _$WaterPathFromJson(Map<String, dynamic> json) => _WaterPath(
  kind: $enumDecode(_$WaterFeatureKindEnumMap, json['kind']),
  points: (json['points'] as List<dynamic>)
      .map((e) => EditorPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  width: (json['width'] as num?)?.toDouble() ?? 48.0,
  variant: $enumDecodeNullable(_$BiomeEnumMap, json['variant']),
);

Map<String, dynamic> _$WaterPathToJson(_WaterPath instance) =>
    <String, dynamic>{
      'kind': _$WaterFeatureKindEnumMap[instance.kind]!,
      'points': instance.points.map((e) => e.toJson()).toList(),
      'width': instance.width,
      'variant': _$BiomeEnumMap[instance.variant],
    };

const _$WaterFeatureKindEnumMap = {
  WaterFeatureKind.river: 'river',
  WaterFeatureKind.lake: 'lake',
  WaterFeatureKind.lava: 'lava',
  WaterFeatureKind.volcanicLake: 'volcanicLake',
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
};
