import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/environment_adaptation.dart';
import 'weather_keyframe.dart';

export '../enums/environment_adaptation.dart';

part 'environment_settings.freezed.dart';
part 'environment_settings.g.dart';

const _defaultKeyframe = WeatherKeyframe(atProgress: 0);

/// A scene's lighting/weather setup, authored in the map editor.
///
/// If [dynamicWeather] is false, [timeline] is treated as a single fixed
/// look (only its first keyframe, if any, is ever sampled) - a "static"
/// environment. If true, [sample] interpolates across [timeline] by match
/// progress, letting weather change over the course of a match.
@freezed
abstract class EnvironmentSettings with _$EnvironmentSettings {
  const factory EnvironmentSettings({
    @Default(true) bool dynamicWeather,

    /// Sun direction as a fraction of a full arc, 0..1 (0 = sunrise/east,
    /// 0.5 = overhead, 1 = sunset/west) - drives ambient light tint/shadow
    /// angle wherever that's rendered.
    @Default(0.5) double sunAngle,
    @Default([_defaultKeyframe]) List<WeatherKeyframe> timeline,

    /// [EnvironmentAdaptation.automatic] (default) keeps every terrain
    /// object (trees) matching this map's own biome.
    /// [EnvironmentAdaptation.manual] lets an author mix tree styles
    /// instead - e.g. snow-dusted trees on a desert map. Wind type is a
    /// separate, always-editable per-keyframe override - see
    /// `WeatherKeyframe.resolvedWindType`.
    @Default(EnvironmentAdaptation.automatic) EnvironmentAdaptation adaptation,
  }) = _EnvironmentSettings;

  factory EnvironmentSettings.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentSettingsFromJson(json);

  const EnvironmentSettings._();

  /// The weather to render at [matchProgress] (0..1) - a straight lerp
  /// between the two surrounding keyframes, or the fixed first keyframe
  /// when [dynamicWeather] is false / [timeline] has one or zero entries.
  WeatherKeyframe sample(double matchProgress) {
    if (timeline.isEmpty) return _defaultKeyframe;
    if (!dynamicWeather || timeline.length == 1) return timeline.first;

    final sorted = [...timeline]
      ..sort((a, b) => a.atProgress.compareTo(b.atProgress));
    if (matchProgress <= sorted.first.atProgress) return sorted.first;
    if (matchProgress >= sorted.last.atProgress) return sorted.last;

    for (var i = 0; i < sorted.length - 1; i++) {
      final from = sorted[i];
      final to = sorted[i + 1];
      if (matchProgress < from.atProgress || matchProgress > to.atProgress) {
        continue;
      }
      final span = to.atProgress - from.atProgress;
      final t = span == 0 ? 0.0 : (matchProgress - from.atProgress) / span;
      return WeatherKeyframe(
        atProgress: matchProgress,
        windStrength: _lerp(from.windStrength, to.windStrength, t),
        rainIntensity: _lerp(from.rainIntensity, to.rainIntensity, t),
        snowIntensity: _lerp(from.snowIntensity, to.snowIntensity, t),
        fogDensity: _lerp(from.fogDensity, to.fogDensity, t),
        cloudCover: _lerp(from.cloudCover, to.cloudCover, t),
        // Discrete, not lerp-able - switches at the halfway point instead.
        windType: t < 0.5 ? from.windType : to.windType,
      );
    }
    return sorted.last;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}
