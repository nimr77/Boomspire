// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_keyframe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeatherKeyframe _$WeatherKeyframeFromJson(Map<String, dynamic> json) =>
    _WeatherKeyframe(
      atProgress: (json['atProgress'] as num).toDouble(),
      windStrength: (json['windStrength'] as num?)?.toDouble() ?? 0.0,
      rainIntensity: (json['rainIntensity'] as num?)?.toDouble() ?? 0.0,
      snowIntensity: (json['snowIntensity'] as num?)?.toDouble() ?? 0.0,
      fogDensity: (json['fogDensity'] as num?)?.toDouble() ?? 0.0,
      cloudCover: (json['cloudCover'] as num?)?.toDouble() ?? 0.0,
      windType:
          $enumDecodeNullable(_$WindTypeEnumMap, json['windType']) ??
          WindType.automatic,
    );

Map<String, dynamic> _$WeatherKeyframeToJson(_WeatherKeyframe instance) =>
    <String, dynamic>{
      'atProgress': instance.atProgress,
      'windStrength': instance.windStrength,
      'rainIntensity': instance.rainIntensity,
      'snowIntensity': instance.snowIntensity,
      'fogDensity': instance.fogDensity,
      'cloudCover': instance.cloudCover,
      'windType': _$WindTypeEnumMap[instance.windType]!,
    };

const _$WindTypeEnumMap = {
  WindType.automatic: 'automatic',
  WindType.grassLeaves: 'grassLeaves',
  WindType.autumnLeaves: 'autumnLeaves',
  WindType.sand: 'sand',
  WindType.dust: 'dust',
  WindType.snow: 'snow',
  WindType.ash: 'ash',
};
