// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'painted_cell.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaintedCell _$PaintedCellFromJson(Map<String, dynamic> json) => _PaintedCell(
  col: (json['col'] as num).toInt(),
  row: (json['row'] as num).toInt(),
  kind: $enumDecode(_$ObstacleKindEnumMap, json['kind']),
  variant: $enumDecodeNullable(_$BiomeEnumMap, json['variant']),
);

Map<String, dynamic> _$PaintedCellToJson(_PaintedCell instance) =>
    <String, dynamic>{
      'col': instance.col,
      'row': instance.row,
      'kind': _$ObstacleKindEnumMap[instance.kind]!,
      'variant': _$BiomeEnumMap[instance.variant],
    };

const _$ObstacleKindEnumMap = {
  ObstacleKind.mountain: 'mountain',
  ObstacleKind.dune: 'dune',
  ObstacleKind.river: 'river',
  ObstacleKind.valley: 'valley',
  ObstacleKind.lake: 'lake',
  ObstacleKind.lava: 'lava',
  ObstacleKind.volcanicLake: 'volcanicLake',
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
