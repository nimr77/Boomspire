import 'dart:ui' as ui;

import 'package:flutter/material.dart' show Colors;

import '../../../../../map_editor/domain/models/weather_keyframe.dart';
import 'paint_rain.dart';
import 'paint_snow.dart';
import 'paint_wind_streaks.dart';

/// Renders the scene's authored live weather look (wind particles, cloud
/// cover tint, fog gradient, rain, snow) on top of the baked terrain -
/// drawn fresh every frame since the weather changes over the course of a
/// match.
void paintWeatherOverlay(
  ui.Canvas canvas,
  WeatherKeyframe weather,
  WindType resolvedType, {
  required double width,
  required double height,
  required double weatherPhase,
}) {
  final rect = ui.Rect.fromLTWH(0, 0, width, height);

  paintWindStreaks(
    canvas,
    weather,
    resolvedType,
    width: width,
    height: height,
    weatherPhase: weatherPhase,
  );

  if (weather.cloudCover > 0) {
    canvas.drawRect(
      rect,
      ui.Paint()
        ..color = const ui.Color(0xFF37474F)
            .withValues(alpha: weather.cloudCover * 0.35),
    );
  }

  if (weather.fogDensity > 0) {
    canvas.drawRect(
      rect,
      ui.Paint()
        ..shader = ui.Gradient.linear(ui.Offset.zero, ui.Offset(0, height), [
          Colors.transparent,
          Colors.white.withValues(alpha: weather.fogDensity * 0.6),
        ]),
    );
  }

  if (weather.rainIntensity > 0) {
    paintRain(
      canvas,
      weather,
      width: width,
      height: height,
      weatherPhase: weatherPhase,
    );
  }

  if (weather.snowIntensity > 0) {
    paintSnow(
      canvas,
      weather,
      width: width,
      height: height,
      weatherPhase: weatherPhase,
    );
  }
}
