import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart' show Colors;

import '../../../../../map_editor/domain/models/weather_keyframe.dart';
import 'ash_particle_position.dart';
import 'paint_sky_flames.dart';
import 'wind_streak_drift.dart';
import 'wind_streak_particle_x.dart';

/// Faint drifting wind-blown particles that scale with wind strength -
/// unlike tree-lean (only visible on tree-bearing biomes), this gives the
/// wind slider a visible effect on every biome/map. The style (green
/// leaves/autumn leaves/sand/dust/snow/ash) comes from [resolvedType] -
/// the biome's own natural look unless the keyframe explicitly overrides
/// it. Positions are reseeded identically every frame (same fixed
/// [math.Random] seed) then shifted by `weatherPhase`, the same
/// looping-drift technique rain/snow use, so particles visibly carry with
/// the wind instead of sitting frozen in place.
void paintWindStreaks(
  ui.Canvas canvas,
  WeatherKeyframe weather,
  WindType resolvedType, {
  required double width,
  required double height,
  required double weatherPhase,
}) {
  if (resolvedType == WindType.ash) {
    paintSkyFlames(
      canvas,
      width: width,
      height: height,
      weatherPhase: weatherPhase,
    );
  }
  if (weather.windStrength <= 0) return;

  final rnd = math.Random(13);
  final strength = weather.windStrength.clamp(0, 1);
  final streakLength = 18 + weather.windStrength * 40;
  final count = (weather.windStrength * 40).round();
  final drift = windStreakDrift(
    weatherPhase: weatherPhase,
    windStrength: weather.windStrength,
  );

  if (resolvedType == WindType.ash) {
    for (var i = 0; i < count; i++) {
      final pos = ashParticlePosition(
        randBaseX: rnd.nextDouble(),
        randBaseY: rnd.nextDouble(),
        randBobPhase: rnd.nextDouble(),
        width: width,
        height: height,
        weatherPhase: weatherPhase,
        drift: drift,
      );
      if (rnd.nextBool()) {
        // A small gray/charcoal ash fleck, not a streak.
        canvas.drawCircle(
          ui.Offset(pos.x, pos.y),
          0.8 + rnd.nextDouble() * 1.4,
          ui.Paint()
            ..color = ui.Color.lerp(
              const ui.Color(0xFF9e9e9e),
              const ui.Color(0xFF2b2b2b),
              rnd.nextDouble(),
            )!.withValues(alpha: 0.3 * strength),
        );
      } else {
        // A drifting burnt-leaf smudge - short, dark, slightly curved.
        canvas.drawLine(
          ui.Offset(pos.x, pos.y),
          ui.Offset(pos.x + streakLength * 0.5, pos.y - streakLength * 0.12),
          ui.Paint()
            ..color = const ui.Color(
              0xFF4a3524,
            ).withValues(alpha: 0.22 * strength)
            ..strokeWidth = 1.6
            ..strokeCap = ui.StrokeCap.round,
        );
      }
    }
    return;
  }

  final color = switch (resolvedType) {
    WindType.grassLeaves => const ui.Color(0xFFB7C97A),
    WindType.autumnLeaves => const ui.Color(0xFFC1502D),
    WindType.sand => const ui.Color(0xFFD8C08A),
    WindType.snow => Colors.white70,
    WindType.dust || WindType.automatic => Colors.white,
    WindType.ash => Colors.white, // unreachable, handled above
  };

  final paint = ui.Paint()
    ..strokeWidth = 1.2
    ..strokeCap = ui.StrokeCap.round;
  for (var i = 0; i < count; i++) {
    final x = windStreakParticleX(
      randBaseX: rnd.nextDouble(),
      width: width,
      drift: drift,
    );
    final baseY = rnd.nextDouble() * height;
    paint.color = color.withValues(alpha: 0.18 * strength);
    canvas.drawLine(
      ui.Offset(x, baseY),
      ui.Offset(x + streakLength, baseY - streakLength * 0.18),
      paint,
    );
  }
}
