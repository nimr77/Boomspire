import 'package:flutter/material.dart';

import 'ally_livery.dart';

/// Paints the friendly tank "2D object model" - flush tracks, hull and
/// turret, sharing the home base's cyan livery.
void paintTank(Canvas canvas) {
  const size = 54.0;
  const center = Offset(size / 2, size / 2);

  canvas.drawOval(
    Rect.fromCenter(center: center, width: size * 0.85, height: size * 0.3),
    Paint()..color = const Color(0x40000000),
  );

  // Flush tracks along the hull's edges instead of one big rounded band
  // (which read as a pair of circles peeking out past the sides).
  for (final dx in [-size * 0.36, size * 0.36]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(dx, 0),
          width: size * 0.14,
          height: size * 0.66,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF1a1c20),
    );
  }

  // Hull.
  final hullRect = Rect.fromCenter(
    center: center,
    width: size * 0.68,
    height: size * 0.46,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(hullRect, const Radius.circular(8)),
    Paint()
      ..shader = const LinearGradient(
        colors: [kAllyHull, kAllyHullDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(hullRect),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(hullRect, const Radius.circular(8)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = kAllyAccent.withValues(alpha: 0.8),
  );

  // Turret.
  canvas.drawCircle(
    center.translate(0, -size * 0.04),
    size * 0.2,
    Paint()
      ..shader = const LinearGradient(colors: [kAllyHull, kAllyHullDark])
          .createShader(Rect.fromCircle(center: center, radius: size * 0.2)),
  );
  canvas.drawCircle(
    center.translate(0, -size * 0.04),
    size * 0.2,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = kAllyAccent,
  );

  // Barrel.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, -size * 0.34),
        width: size * 0.1,
        height: size * 0.4,
      ),
      const Radius.circular(3),
    ),
    Paint()..color = const Color(0xFF1a1c20),
  );
}
