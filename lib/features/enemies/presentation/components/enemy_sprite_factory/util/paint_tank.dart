import 'package:flutter/material.dart';

/// Paints the enemy tank "2D object model" - tracked hull, round turret,
/// forward barrel.
void paintTank(Canvas canvas) {
  const size = 54.0;
  const center = Offset(size / 2, size / 2);

  canvas.drawOval(
    Rect.fromCenter(center: center, width: size * 0.85, height: size * 0.3),
    Paint()..color = const Color(0x40000000),
  );

  // Flush tracks along the hull's edges - narrow rectangles instead of
  // round pods, so they read as treads rather than a pair of bug legs.
  for (final dx in [-size * 0.3, size * 0.3]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(dx, size * 0.06),
          width: size * 0.13,
          height: size * 0.6,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF1a1c20),
    );
  }

  // Hull.
  final hullRect = Rect.fromCenter(
    center: center,
    width: size * 0.58,
    height: size * 0.4,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(hullRect, const Radius.circular(6)),
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6D4C41), Color(0xFF3E2723)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(hullRect),
  );

  // Turret + barrel, pointed "up" (forward) by default.
  canvas.drawCircle(
    center,
    size * 0.19,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8D6E63), Color(0xFF3E2723)],
      ).createShader(Rect.fromCircle(center: center, radius: size * 0.19)),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, -size * 0.28),
        width: size * 0.09,
        height: size * 0.34,
      ),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFF2b2f36),
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, size * 0.02),
        width: size * 0.1,
        height: size * 0.04,
      ),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFFE53935),
  );

  // Headlight - small warm beacon on the hull front, doubles as the
  // "alive" light other vehicle types also carry.
  canvas.drawCircle(
    center.translate(0, size * 0.16),
    size * 0.045,
    Paint()..color = const Color(0xFFFFF59D),
  );
}
