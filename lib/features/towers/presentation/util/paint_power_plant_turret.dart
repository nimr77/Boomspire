import 'package:flutter/material.dart';

/// A lightning bolt over a glowing coil - reads as an energy generator,
/// not a weapon.
void paintPowerPlantTurret(Canvas canvas, Offset center) {
  final bolt = Path()
    ..moveTo(center.dx + 2, center.dy - 20)
    ..lineTo(center.dx - 5, center.dy - 4)
    ..lineTo(center.dx + 1, center.dy - 4)
    ..lineTo(center.dx - 3, center.dy + 12)
    ..lineTo(center.dx + 7, center.dy - 6)
    ..lineTo(center.dx + 1, center.dy - 6)
    ..close();
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF42A5F5), Color(0xFF14314f)],
      ).createShader(Rect.fromCircle(center: center, radius: 12)),
  );
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF42A5F5),
  );
  canvas.drawPath(bolt, Paint()..color = const Color(0xFFFFEE58));
  canvas.drawPath(
    bolt,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFFFF9C4),
  );
}
