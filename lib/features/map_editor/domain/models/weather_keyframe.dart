import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../terrain/domain/enums/biome.dart';
import '../../../terrain/domain/enums/wind_type.dart';
import '../../../terrain/extensions/biome_extensions.dart';

export '../../../terrain/domain/enums/wind_type.dart';

part 'weather_keyframe.freezed.dart';
part 'weather_keyframe.g.dart';

/// One point on a scene's weather timeline - every intensity is 0..1.
/// Runtime rendering interpolates between the two keyframes surrounding the
/// match's current progress (see `EnvironmentSettings.dynamicWeather`).
@freezed
abstract class WeatherKeyframe with _$WeatherKeyframe {
  const factory WeatherKeyframe({
    /// How far through the match this keyframe applies, 0 (start) to 1 (end).
    required double atProgress,
    @Default(0.0) double windStrength,
    @Default(0.0) double rainIntensity,
    @Default(0.0) double snowIntensity,
    @Default(0.0) double fogDensity,
    @Default(0.0) double cloudCover,

    /// [WindType.automatic] (the default) inherits the map's own biome's
    /// natural wind look - see [resolvedWindType]. Any other value is an
    /// explicit author override, always editable per-keyframe regardless
    /// of any other setting - same self-contained pattern as a brush's own
    /// biome-variant override.
    @Default(WindType.automatic) WindType windType,
  }) = _WeatherKeyframe;

  factory WeatherKeyframe.fromJson(Map<String, dynamic> json) =>
      _$WeatherKeyframeFromJson(json);

  const WeatherKeyframe._();

  /// The wind-blown particle style to actually render - [windType] itself,
  /// unless it's left on [WindType.automatic], in which case this resolves
  /// to [biome]'s own natural look (`BiomeExtensions.defaultWindType`).
  WindType resolvedWindType(Biome biome) =>
      windType == WindType.automatic ? biome.defaultWindType : windType;
}
