import 'package:flutter/material.dart';

import 'paint_viewhole.dart';

/// A rotating comms antenna array with a beacon light - reads as a
/// command/support structure that coordinates rather than fires.
void paintCommandPostTurret(Canvas canvas, Offset center) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -8), width: 4, height: 20),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFF3a3220),
  );
  for (final side in [-1.0, 1.0]) {
    canvas.drawLine(
      center.translate(0, -18),
      center.translate(side * 8, -12),
      Paint()
        ..color = const Color(0xFFFFD54A)
        ..strokeWidth = 1.5,
    );
  }
  canvas.drawCircle(
    center.translate(0, -19),
    2.4,
    Paint()..color = const Color(0xFFFFF176),
  );
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFb89a4a), Color(0xFF2b2f36)],
      ).createShader(Rect.fromCircle(center: center, radius: 12)),
  );
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFFD54A),
  );
  paintViewhole(canvas, center.translate(0, 7));
}
