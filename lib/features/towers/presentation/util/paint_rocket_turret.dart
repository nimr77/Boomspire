import 'package:flutter/material.dart';

import 'paint_viewhole.dart';

/// Three-tube launch pod - reads closer to a real MLRS battery.
void paintRocketTurret(Canvas canvas, Offset center) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -8), width: 20, height: 32),
      const Radius.circular(4),
    ),
    Paint()..color = const Color(0xFF3a3f47),
  );
  for (final dx in [-6.0, 0.0, 6.0]) {
    canvas.drawCircle(
      Offset(center.dx + dx, center.dy - 22),
      4.2,
      Paint()..color = const Color(0xFF1a1c20),
    );
    canvas.drawCircle(
      Offset(center.dx + dx, center.dy - 22),
      4.2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF6b6f76),
    );
  }
  canvas.drawCircle(
    center,
    13,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9a4a34), Color(0xFF2b2f36)],
      ).createShader(Rect.fromCircle(center: center, radius: 13)),
  );
  canvas.drawCircle(
    center,
    13,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFF6B35),
  );
  paintViewhole(canvas, center.translate(-7, 6));
}
