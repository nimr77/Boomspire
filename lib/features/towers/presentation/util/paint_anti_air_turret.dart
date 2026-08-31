import 'package:flutter/material.dart';

import 'paint_viewhole.dart';

/// Twin angled flak barrels pointed skyward, each with a muzzle collar.
void paintAntiAirTurret(Canvas canvas, Offset center) {
  for (final side in [-1.0, 1.0]) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(side * -0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -14), width: 5, height: 24),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF35284f),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -25), width: 6.5, height: 5),
        const Radius.circular(1.5),
      ),
      Paint()..color = const Color(0xFF1a1420),
    );
    canvas.restore();
  }
  // Ammo feed box at the base - reads closer to a real flak/AA mount.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, 9), width: 12, height: 8),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFF2b2436),
  );
  canvas.drawCircle(
    center,
    11,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9575CD), Color(0xFF2b2f36)],
      ).createShader(Rect.fromCircle(center: center, radius: 11)),
  );
  canvas.drawCircle(
    center,
    11,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF7C4DFF),
  );
  paintViewhole(canvas, center.translate(-6, -1));
}
