import 'package:flutter/material.dart';

import 'paint_viewhole.dart';

/// Three-barrel rotary cluster - reads closer to a real minigun/gatling.
void paintMachineGunTurret(Canvas canvas, Offset center) {
  for (final dx in [-6.0, 0.0, 6.0]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(dx, -9),
          width: 4.5,
          height: 25,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF2b2f36),
    );
  }
  canvas.drawCircle(
    center.translate(0, -18),
    6,
    Paint()..color = const Color(0xFF1a1c20),
  );
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF7a8592), Color(0xFF2b2f36)],
      ).createShader(Rect.fromCircle(center: center, radius: 12)),
  );
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF4FC3F7),
  );
  paintViewhole(canvas, center.translate(0, 7));
}
