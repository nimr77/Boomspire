import 'dart:ui' as ui;

import 'package:flutter/material.dart' show Colors;

import 'sun_light_metrics.dart';

/// Sun-driven ambient lighting overlay: a night-tint darkening plus a warm
/// directional rim-light gradient from whichever side the sun sits on.
void paintSunLight(
  ui.Canvas canvas,
  double sunAngle, {
  required double width,
  required double height,
}) {
  final rect = ui.Rect.fromLTWH(0, 0, width, height);
  final sun = sunLightMetrics(sunAngle);

  canvas.drawRect(
    rect,
    ui.Paint()
      ..color = const ui.Color(
        0xFF120A24,
      ).withValues(alpha: (1 - sun.sunHeight) * 0.4),
  );

  final from = sun.sunFromRight ? ui.Offset(width, 0) : ui.Offset.zero;
  final to = sun.sunFromRight ? ui.Offset.zero : ui.Offset(width, 0);
  canvas.drawRect(
    rect,
    ui.Paint()
      ..shader = ui.Gradient.linear(from, to, [
        sun.warmTint.withValues(alpha: 0.12 + (1 - sun.sunHeight) * 0.28),
        Colors.transparent,
      ]),
  );
}
