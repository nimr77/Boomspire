import 'package:flutter/material.dart';

import 'paint_viewhole.dart';

/// A tilted dish on a mast - reads as a sensor/uplink structure rather
/// than a weapon, since it never actually fires.
void paintTechLabTurret(Canvas canvas, Offset center) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -6), width: 4, height: 18),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFF2b2f36),
  );
  canvas.save();
  canvas.translate(center.dx, center.dy - 16);
  canvas.rotate(-0.4);
  canvas.drawArc(
    Rect.fromCenter(center: Offset.zero, width: 22, height: 16),
    3.4,
    3.0,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF1DE9B6),
  );
  canvas.drawCircle(Offset.zero, 2, Paint()..color = const Color(0xFFE0FFF6));
  canvas.restore();
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2e6b5f), Color(0xFF2b2f36)],
      ).createShader(Rect.fromCircle(center: center, radius: 12)),
  );
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF1DE9B6),
  );
  paintViewhole(canvas, center.translate(0, 7));
}
