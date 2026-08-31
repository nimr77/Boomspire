import 'package:flutter/material.dart';

/// Paints the enemy rocket-barrage vehicle "2D object model" - a launcher
/// pod with three visible rocket tubes atop a tracked chassis.
void paintRocketBarrage(Canvas canvas) {
  const size = 50.0;
  const center = Offset(size / 2, size / 2);

  canvas.drawOval(
    Rect.fromCenter(center: center, width: size * 0.86, height: size * 0.3),
    Paint()..color = const Color(0x40000000),
  );

  final bodyRect = Rect.fromCenter(
    center: center.translate(0, size * 0.1),
    width: size * 0.62,
    height: size * 0.56,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)),
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5D4037), Color(0xFF2E1A16)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bodyRect),
  );

  final podRect = Rect.fromCenter(
    center: center.translate(0, -size * 0.22),
    width: size * 0.5,
    height: size * 0.3,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(podRect, const Radius.circular(4)),
    Paint()..color = const Color(0xFF37474F),
  );
  for (final dx in [-size * 0.16, 0.0, size * 0.16]) {
    canvas.drawCircle(
      center.translate(dx, -size * 0.22),
      size * 0.06,
      Paint()..color = const Color(0xFFE53935),
    );
  }

  // Wheel-wells - flush rectangles instead of free-floating circles, so
  // the chassis reads as a vehicle rather than a bug's legs.
  for (final dy in [-size * 0.06, size * 0.32]) {
    for (final dx in [-size * 0.32, size * 0.32]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, dy),
            width: size * 0.14,
            height: size * 0.22,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF0d0d0d),
      );
    }
  }
}
