import 'package:flutter/material.dart';

import 'paint_viewhole.dart';

/// A stubby smokestack with a crane arm - reads as heavy industry rather
/// than a weapon, since it never actually fires; it just rolls out
/// vehicles and aircraft.
void paintWarFactoryTurret(Canvas canvas, Offset center) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(-5, -8), width: 7, height: 22),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFF78909C),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(-5, -20), width: 9, height: 5),
      const Radius.circular(1.5),
    ),
    Paint()..color = const Color(0xFF37474F),
  );
  canvas.drawLine(
    center.translate(2, -14),
    center.translate(12, -18),
    Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 2,
  );
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF607d8b), Color(0xFF2b2f36)],
      ).createShader(Rect.fromCircle(center: center, radius: 12)),
  );
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFB0BEC5),
  );
  paintViewhole(canvas, center.translate(0, 7));
}
