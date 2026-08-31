import 'dart:math';

import 'package:flutter/material.dart';

/// The default hexagonal weapon-mount base plate shared by every combat
/// tower, tinted with the tower's [accent] color.
void paintDefaultBase(Canvas canvas, Color accent) {
  const center = Offset(32, 32);

  final path = Path();
  for (var i = 0; i < 6; i++) {
    final a = pi / 6 + i * pi / 3;
    final p = Offset(center.dx + cos(a) * 28, center.dy + sin(a) * 28);
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  path.close();

  canvas.drawShadow(path, const Color(0xFF000000), 4, false);
  canvas.drawPath(
    path,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF636d7a), Color(0xFF20242a)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: 30)),
  );
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = accent.withValues(alpha: 0.85),
  );
  canvas.drawCircle(center, 10, Paint()..color = const Color(0xFF11151a));
  canvas.drawCircle(
    center,
    10,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = accent,
  );
}
