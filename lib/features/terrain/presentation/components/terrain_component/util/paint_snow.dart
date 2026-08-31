import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart' show Colors;

import '../../../../../map_editor/domain/models/weather_keyframe.dart';
import 'snow_flake_metrics.dart';

/// Snow drifts down slowly with a gentle side-to-side sway (scaled by
/// [WeatherKeyframe.windStrength]) instead of sitting frozen in place -
/// same looping-fall approach as rain, just much slower. Each flake gets
/// its own size/speed/sway/alpha so the flurry doesn't look like one
/// repeating stamp.
void paintSnow(
  ui.Canvas canvas,
  WeatherKeyframe weather, {
  required double width,
  required double height,
  required double weatherPhase,
}) {
  final rnd = math.Random(9);
  const fallSpeed = 60.0;
  for (var i = 0; i < (weather.snowIntensity * 110).round(); i++) {
    final flake = snowFlakeMetrics(
      randBaseX: rnd.nextDouble(),
      randBaseY: rnd.nextDouble(),
      randDriftPhase: rnd.nextDouble(),
      randSpeedMul: rnd.nextDouble(),
      randRadius: rnd.nextDouble(),
      randAlpha: rnd.nextDouble(),
      randSway: rnd.nextDouble(),
      width: width,
      height: height,
      weatherPhase: weatherPhase,
      fallSpeed: fallSpeed,
      windStrength: weather.windStrength,
    );
    canvas.drawCircle(
      ui.Offset(flake.x, flake.y),
      flake.radius,
      ui.Paint()..color = Colors.white.withValues(alpha: flake.alpha),
    );
  }
}
