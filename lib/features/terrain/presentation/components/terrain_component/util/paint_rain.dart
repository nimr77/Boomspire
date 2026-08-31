import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart' show Colors;

import '../../../../../map_editor/domain/models/weather_keyframe.dart';
import 'rain_drop_metrics.dart';

/// Rain streaks fall straight down, looping back to the top once they
/// pass the bottom edge - `weatherPhase` (elapsed seconds) drives the
/// fall instead of every frame redrawing the same frozen positions.
/// [WeatherKeyframe.windStrength] still leans each streak's angle. Each
/// streak gets its own speed/length/width/alpha so the rain reads as a
/// mix of near/far drops instead of one uniform pattern, and a slight
/// blur softens the streaks like a wet-glass look.
void paintRain(
  ui.Canvas canvas,
  WeatherKeyframe weather, {
  required double width,
  required double height,
  required double weatherPhase,
}) {
  final rnd = math.Random(7);
  final lean = weather.windStrength * 10;
  const fallSpeed = 420.0;
  final paint = ui.Paint()
    ..strokeCap = ui.StrokeCap.round
    ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 0.9);
  for (var i = 0; i < (weather.rainIntensity * 160).round(); i++) {
    final drop = rainDropMetrics(
      randX: rnd.nextDouble(),
      randBaseY: rnd.nextDouble(),
      randSpeedMul: rnd.nextDouble(),
      randLength: rnd.nextDouble(),
      randAlpha: rnd.nextDouble(),
      randStrokeWidth: rnd.nextDouble(),
      width: width,
      height: height,
      weatherPhase: weatherPhase,
      fallSpeed: fallSpeed,
    );
    paint
      ..color = Colors.lightBlueAccent.withValues(alpha: drop.alpha)
      ..strokeWidth = drop.strokeWidth;
    canvas.drawLine(
      ui.Offset(drop.x, drop.y),
      ui.Offset(drop.x + lean * drop.speedMul, drop.y + drop.length),
      paint,
    );
  }
}
