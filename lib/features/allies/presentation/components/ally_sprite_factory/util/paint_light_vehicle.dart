import 'package:flutter/material.dart';

import 'ally_livery.dart';

/// Paints the friendly light vehicle "2D object model" - a roof-mounted
/// gun jeep, sharing the home base's cyan livery.
void paintLightVehicle(Canvas canvas) {
  const size = 46.0;
  const center = Offset(size / 2, size / 2);

  canvas.drawOval(
    Rect.fromCenter(center: center, width: size * 0.8, height: size * 0.26),
    Paint()..color = const Color(0x40000000),
  );

  final bodyRect = Rect.fromCenter(
    center: center,
    width: size * 0.56,
    height: size * 0.6,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
    Paint()
      ..shader = const LinearGradient(
        colors: [kAllyHull, kAllyHullDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bodyRect),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = kAllyAccent.withValues(alpha: 0.8),
  );

  // Windshield.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, -size * 0.14),
        width: size * 0.32,
        height: size * 0.16,
      ),
      const Radius.circular(3),
    ),
    Paint()..color = kAllyAccent.withValues(alpha: 0.55),
  );

  // Roof-mounted gun.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, size * 0.06),
        width: size * 0.08,
        height: size * 0.26,
      ),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFF1a1c20),
  );

  // Wheels - small flush rectangles tucked against the body's edge,
  // instead of free-floating circles bulging past the silhouette.
  for (final dy in [-size * 0.22, size * 0.22]) {
    for (final dx in [-size * 0.3, size * 0.3]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, dy),
            width: size * 0.12,
            height: size * 0.2,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF0d0d0d),
      );
    }
  }
}
