import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Paints `HumanLimbsComponent`'s scissoring leg strokes plus (while
/// [fireFlash] is active) the brief arm/weapon kick stroke.
void paintHumanLimbs(
  Canvas canvas, {
  required Vector2 size,
  required Color accent,
  required double phase,
  required double fireFlash,
  required double fireFlashDuration,
}) {
  // Flame renders every component in a top-left-origin 0..size box
  // regardless of anchor, so "centered on the body" requires explicitly
  // offsetting by half the hull size here rather than drawing around
  // (0, 0) - otherwise the limbs render a half-hull-width/height away
  // from the actual torso.
  final cx = size.x / 2;
  final cy = size.y / 2;
  final legSwing = sin(phase) * size.y * 0.16;
  final legPaint = Paint()
    ..color = const Color(0xFF2A2D31)
    ..strokeWidth = size.x * 0.09
    ..strokeCap = StrokeCap.round;
  final hipY = cy + size.y * 0.28;
  canvas.drawLine(
    Offset(cx - size.x * 0.1, hipY),
    Offset(cx - size.x * 0.1 + legSwing * 0.3, hipY + size.y * 0.34),
    legPaint,
  );
  canvas.drawLine(
    Offset(cx + size.x * 0.1, hipY),
    Offset(cx + size.x * 0.1 - legSwing * 0.3, hipY + size.y * 0.34),
    legPaint,
  );

  if (fireFlash > 0) {
    final armPaint = Paint()
      ..color = accent.withValues(
        alpha: (fireFlash / fireFlashDuration).clamp(0.0, 1.0),
      )
      ..strokeWidth = size.x * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx + size.x * 0.12, cy - size.y * 0.05),
      Offset(cx + size.x * 0.42, cy - size.y * 0.22),
      armPaint,
    );
  }
}
