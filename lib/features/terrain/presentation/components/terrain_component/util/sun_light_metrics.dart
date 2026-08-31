import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' show Colors;

SunLightMetrics sunLightMetrics(double sunAngle) {
  final sunHeight = sin(sunAngle * pi).clamp(0.0, 1.0);
  final sunFromRight = cos(sunAngle * pi) >= 0;
  final warmTint = ui.Color.lerp(
    const ui.Color(0xFFFF8A3D),
    Colors.white,
    sunHeight,
  )!;
  return (sunHeight: sunHeight, sunFromRight: sunFromRight, warmTint: warmTint);
}

/// Sun-driven ambient lighting for one frame: how high the sun currently
/// sits (`0` = below the horizon, `1` = directly overhead - drives both
/// the night-tint darkness and the warm rim-light strength), which side
/// of the arena it's shining from, and the warm tint color blended toward
/// white as the sun climbs. Used by `TerrainComponent._paintSunLight`.
typedef SunLightMetrics = ({
  double sunHeight,
  bool sunFromRight,
  ui.Color warmTint,
});
