import 'package:flutter/material.dart';

import 'paint_viewhole.dart';

/// A boxy multi-tube launcher angled skyward - reads as long-range
/// artillery built to reach big/armored targets rather than a nimble gun.
void paintRocketSiloTurret(Canvas canvas, Offset center) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(-0.15);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -10), width: 22, height: 26),
      const Radius.circular(3),
    ),
    Paint()..color = const Color(0xFF4a3a28),
  );
  for (final dx in [-6.0, 0.0, 6.0]) {
    canvas.drawCircle(
      Offset(dx, -18),
      3.2,
      Paint()..color = const Color(0xFF1c1712),
    );
    canvas.drawCircle(
      Offset(dx, -18),
      3.2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFFF8A00),
    );
  }
  canvas.restore();
  canvas.drawCircle(
    center,
    13,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8a5a2a), Color(0xFF2b2f36)],
      ).createShader(Rect.fromCircle(center: center, radius: 13)),
  );
  canvas.drawCircle(
    center,
    13,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFF8A00),
  );
  paintViewhole(canvas, center.translate(0, 8));
}
