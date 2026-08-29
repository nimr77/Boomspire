// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EnvironmentSettings _$EnvironmentSettingsFromJson(Map<String, dynamic> json) =>
    _EnvironmentSettings(
      dynamicWeather: json['dynamicWeather'] as bool? ?? true,
      sunAngle: (json['sunAngle'] as num?)?.toDouble() ?? 0.5,
      timeline:
          (json['timeline'] as List<dynamic>?)
              ?.map((e) => WeatherKeyframe.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [_defaultKeyframe],
      adaptation:
          $enumDecodeNullable(
            _$EnvironmentAdaptationEnumMap,
            json['adaptation'],
          ) ??
          EnvironmentAdaptation.automatic,
    );

Map<String, dynamic> _$EnvironmentSettingsToJson(
  _EnvironmentSettings instance,
) => <String, dynamic>{
  'dynamicWeather': instance.dynamicWeather,
  'sunAngle': instance.sunAngle,
  'timeline': instance.timeline.map((e) => e.toJson()).toList(),
  'adaptation': _$EnvironmentAdaptationEnumMap[instance.adaptation]!,
};

const _$EnvironmentAdaptationEnumMap = {
  EnvironmentAdaptation.automatic: 'automatic',
  EnvironmentAdaptation.manual: 'manual',
};
