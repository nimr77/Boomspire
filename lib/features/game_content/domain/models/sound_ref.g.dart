// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SoundRef _$SoundRefFromJson(Map<String, dynamic> json) => _SoundRef(
  type: $enumDecodeNullable(_$SoundSourceTypeEnumMap, json['type']),
  path: json['path'] as String?,
);

Map<String, dynamic> _$SoundRefToJson(_SoundRef instance) => <String, dynamic>{
  'type': _$SoundSourceTypeEnumMap[instance.type],
  'path': instance.path,
};

const _$SoundSourceTypeEnumMap = {
  SoundSourceType.builtIn: 'builtIn',
  SoundSourceType.remote: 'remote',
};
