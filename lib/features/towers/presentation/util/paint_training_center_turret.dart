import 'package:flutter/material.dart';

import 'paint_viewhole.dart';

/// A small flagpole with a fluttering pennant - reads as a barracks/muster
/// point rather than a weapon, since it never actually fires; it just
/// musters fresh soldiers to send out.
void paintTrainingCenterTurret(Canvas canvas, Offset center) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -6), width: 3, height: 20),
      const Radius.circular(1.5),
    ),
    Paint()..color = const Color(0xFF2b2f36),
  );
  final flag = Path()
    ..moveTo(center.dx + 1.5, center.dy - 15)
    ..lineTo(center.dx + 11, center.dy - 12)
    ..lineTo(center.dx + 1.5, center.dy - 8)
    ..close();
  canvas.drawPath(flag, Paint()..color = const Color(0xFF66BB6A));
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4c7a4f), Color(0xFF2b2f36)],
      ).createShader(Rect.fromCircle(center: center, radius: 12)),
  );
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF66BB6A),
  );
  paintViewhole(canvas, center.translate(0, 7));
}
