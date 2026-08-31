import 'package:flutter/material.dart';

import 'paint_viewhole.dart';

/// A short, wide reinforced barrel on a squat mount - heavier and more
/// armored-looking than the Siege Cannon, built to endure return fire.
void paintArtilleryBunkerTurret(Canvas canvas, Offset center) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -6), width: 20, height: 20),
      const Radius.circular(3),
    ),
    Paint()..color = const Color(0xFF4e4038),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -18), width: 12, height: 20),
      const Radius.circular(4),
    ),
    Paint()..color = const Color(0xFF6d5a4e),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -28), width: 14, height: 6),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFF2b2318),
  );
  canvas.drawCircle(
    center,
    13,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8D6E63), Color(0xFF2b2f36)],
      ).createShader(Rect.fromCircle(center: center, radius: 13)),
  );
  canvas.drawCircle(
    center,
    13,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF8D6E63),
  );
  paintViewhole(canvas, center.translate(-7, 6));
}
