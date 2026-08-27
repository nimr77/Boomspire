// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'painted_cell.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaintedCell _$PaintedCellFromJson(Map<String, dynamic> json) => _PaintedCell(
  col: (json['col'] as num).toInt(),
  row: (json['row'] as num).toInt(),
  kind: $enumDecode(_$ObstacleKindEnumMap, json['kind']),
);

Map<String, dynamic> _$PaintedCellToJson(_PaintedCell instance) =>
    <String, dynamic>{
      'col': instance.col,
      'row': instance.row,
      'kind': _$ObstacleKindEnumMap[instance.kind]!,
    };

const _$ObstacleKindEnumMap = {
  ObstacleKind.mountain: 'mountain',
  ObstacleKind.dune: 'dune',
  ObstacleKind.river: 'river',
  ObstacleKind.valley: 'valley',
};
