import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Alignment, LinearGradient;

/// Paints the resource node's hexagonal "building" plate - accent ring +
/// core - tinted by [accent] (neutral grey while unclaimed).
void paintResourceNodePlate(
  Canvas canvas, {
  required Vector2 size,
  required Color accent,
}) {
  final center = Offset(size.x / 2, size.y / 2);
  final radius = size.x / 2;

  final path = Path();
  for (var i = 0; i < 6; i++) {
    final a = pi / 6 + i * pi / 3;
    final p = Offset(center.dx + cos(a) * radius, center.dy + sin(a) * radius);
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  path.close();

  canvas.drawShadow(path, const Color(0xFF000000), 3, false);
  canvas.drawPath(
    path,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF636d7a), Color(0xFF20242a)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius)),
  );
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = accent.withValues(alpha: 0.85),
  );
  canvas.drawCircle(
    center,
    radius * 0.32,
    Paint()..color = const Color(0xFF11151a),
  );
  canvas.drawCircle(
    center,
    radius * 0.32,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = accent,
  );
}
