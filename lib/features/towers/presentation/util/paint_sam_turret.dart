import 'package:flutter/material.dart';

import 'paint_viewhole.dart';

/// A single missile tube tilted skyward on a launcher box - reads as a
/// dedicated long-range AA site rather than a rapid-fire flak mount.
void paintSamTurret(Canvas canvas, Offset center) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(-0.35);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -15), width: 6, height: 26),
      const Radius.circular(3),
    ),
    Paint()..color = const Color(0xFF1c3d42),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -27), width: 4, height: 8),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFFFF6B35),
  );
  canvas.restore();
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, 8), width: 16, height: 9),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFF16282b),
  );
  canvas.drawCircle(
    center,
    11,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2b6e78), Color(0xFF2b2f36)],
      ).createShader(Rect.fromCircle(center: center, radius: 11)),
  );
  canvas.drawCircle(
    center,
    11,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF00E5FF),
  );
  paintViewhole(canvas, center.translate(-6, 6));
}
