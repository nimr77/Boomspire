import 'package:flutter/material.dart';

import 'ally_livery.dart';

/// Paints the friendly aircraft "2D object model" - a delta-wing fighter
/// silhouette sharing the home base's cyan livery.
void paintAircraft(Canvas canvas) {
  const size = 50.0;
  const center = Offset(size / 2, size / 2);

  canvas.drawOval(
    Rect.fromCenter(center: center, width: size * 0.7, height: size * 0.22),
    Paint()..color = const Color(0x40000000),
  );

  final wingPath = Path()
    ..moveTo(center.dx, center.dy - size * 0.4)
    ..lineTo(center.dx + size * 0.46, center.dy + size * 0.34)
    ..lineTo(center.dx + size * 0.1, center.dy + size * 0.2)
    ..lineTo(center.dx, center.dy + size * 0.4)
    ..lineTo(center.dx - size * 0.1, center.dy + size * 0.2)
    ..lineTo(center.dx - size * 0.46, center.dy + size * 0.34)
    ..close();
  canvas.drawPath(
    wingPath,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFCFD8DC), kAllyHull],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: size * 0.4)),
  );
  canvas.drawPath(
    wingPath,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = kAllyAccent.withValues(alpha: 0.8),
  );

  canvas.drawOval(
    Rect.fromCenter(
      center: center.translate(0, -size * 0.06),
      width: size * 0.13,
      height: size * 0.28,
    ),
    Paint()..color = const Color(0xFF1a1c20),
  );
  canvas.drawOval(
    Rect.fromCenter(
      center: center.translate(0, -size * 0.1),
      width: size * 0.08,
      height: size * 0.14,
    ),
    Paint()..color = kAllyAccent.withValues(alpha: 0.9),
  );

  for (final dx in [-size * 0.12, size * 0.12]) {
    canvas.drawCircle(
      center.translate(dx, size * 0.36),
      size * 0.06,
      Paint()
        ..color = kAllyAccent.withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }
}
