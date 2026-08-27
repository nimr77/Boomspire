import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'player_palette.dart';

/// Draws a single numbered, colored skirmish home-site marker (shadow +
/// filled circle + white ring + bold number label) - shared by the map
/// editor canvas and the pre-game placement screen so both agree on the
/// same look.
void paintHomeSiteMarker(
  Canvas canvas,
  Offset center,
  int index, {
  double radius = 14,
  bool highlighted = false,
}) {
  final color = PlayerPalette.colorFor(index);
  canvas.drawCircle(
    center,
    radius + 2,
    Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4),
  );
  canvas.drawCircle(center, radius, Paint()..color = color);
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = highlighted ? 3 : 2
      ..color = Colors.white,
  );
  final textPainter = TextPainter(
    text: TextSpan(
      text: '${index + 1}',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: radius > 16 ? 15 : 13,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  textPainter.paint(
    canvas,
    center - Offset(textPainter.width / 2, textPainter.height / 2),
  );
}
