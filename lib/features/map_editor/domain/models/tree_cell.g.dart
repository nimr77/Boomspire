// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_cell.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TreeCell _$TreeCellFromJson(Map<String, dynamic> json) => _TreeCell(
  col: (json['col'] as num).toInt(),
  row: (json['row'] as num).toInt(),
  variant: $enumDecodeNullable(_$BiomeEnumMap, json['variant']),
);

Map<String, dynamic> _$TreeCellToJson(_TreeCell instance) => <String, dynamic>{
  'col': instance.col,
  'row': instance.row,
  'variant': _$BiomeEnumMap[instance.variant],
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
