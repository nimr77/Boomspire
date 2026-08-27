import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _WeatherKeyframe;

  factory WeatherKeyframe.fromJson(Map<String, dynamic> json) =>
      _$WeatherKeyframeFromJson(json);
}
