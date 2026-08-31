import 'package:flutter/material.dart';

import 'paint_viewhole.dart';

/// A single thick barrel with a muzzle brake - reads as "heavy artillery".
void paintCannonTurret(Canvas canvas, Offset center) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -9), width: 16, height: 34),
      const Radius.circular(5),
    ),
    Paint()..color = const Color(0xFF454b52),
  );
  for (final dy in [-24.0, -20.0]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, dy), width: 21, height: 3),
        const Radius.circular(1.5),
      ),
      Paint()..color = const Color(0xFF23262b),
    );
  }
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -24), width: 19, height: 8),
      const Radius.circular(3),
    ),
    Paint()..color = const Color(0xFF23262b),
  );
  canvas.drawCircle(
    center,
    14,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8d8060), Color(0xFF2b2f36)],
      ).createShader(Rect.fromCircle(center: center, radius: 14)),
  );
  canvas.drawCircle(
    center,
    14,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFFC107),
  );
  paintViewhole(canvas, center.translate(8, 6));
}
