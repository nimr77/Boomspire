// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssetSource _$AssetSourceFromJson(Map<String, dynamic> json) => _AssetSource(
  type:
      $enumDecodeNullable(_$AssetSourceTypeEnumMap, json['type']) ??
      AssetSourceType.assets,
  path: json['path'] as String,
);

Map<String, dynamic> _$AssetSourceToJson(_AssetSource instance) =>
    <String, dynamic>{
      'type': _$AssetSourceTypeEnumMap[instance.type]!,
      'path': instance.path,
    };

const _$AssetSourceTypeEnumMap = {
  AssetSourceType.assets: 'assets',
  AssetSourceType.remote: 'remote',
};
