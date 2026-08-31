import 'package:flutter/material.dart';

/// A small ore headframe (A-frame + pulley wheel) over a pile of gold
/// nuggets - reads as an economy structure, not a weapon.
void paintGoldMineTurret(Canvas canvas, Offset center) {
  for (final side in [-1.0, 1.0]) {
    canvas.drawLine(
      center.translate(side * 8, 10),
      center.translate(0, -16),
      Paint()
        ..color = const Color(0xFF6d4c1f)
        ..strokeWidth = 2.5,
    );
  }
  canvas.drawCircle(
    center.translate(0, -16),
    3,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFFD54A),
  );
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD54A), Color(0xFF7a5a1a)],
      ).createShader(Rect.fromCircle(center: center, radius: 12)),
  );
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFFB300),
  );
  // Gold nuggets scattered at the base.
  for (final offset in [
    const Offset(-6, 8),
    const Offset(5, 9),
    const Offset(0, 11),
  ]) {
    canvas.drawCircle(
      center.translate(offset.dx, offset.dy),
      2.2,
      Paint()..color = const Color(0xFFFFE082),
    );
  }
}
