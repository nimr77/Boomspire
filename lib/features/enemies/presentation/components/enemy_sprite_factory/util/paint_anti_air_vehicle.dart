import 'package:flutter/material.dart';

/// Paints the enemy anti-air vehicle "2D object model" - twin flak
/// barrels angled skyward, a hull-mounted radar dish.
void paintAntiAirVehicle(Canvas canvas) {
  const size = 52.0;
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
        colors: [Color(0xFF78909C), Color(0xFF263238)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(hullRect),
  );

  // Twin flak barrels, angled skyward instead of a tank's single
  // forward-pointed barrel - the visual cue that this vehicle shoots air
  // targets too.
  for (final dx in [-size * 0.08, size * 0.08]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(dx, -size * 0.3),
          width: size * 0.07,
          height: size * 0.32,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF2b2f36),
    );
  }

  // Radar dish on the deck.
  canvas.drawCircle(
    center.translate(0, -size * 0.02),
    size * 0.13,
    Paint()..color = const Color(0xFF37474F),
  );
  canvas.drawCircle(
    center.translate(0, -size * 0.02),
    size * 0.08,
    Paint()..color = const Color(0xFFFFCA28).withValues(alpha: 0.85),
  );

  canvas.drawCircle(
    center.translate(0, size * 0.16),
    size * 0.045,
    Paint()..color = const Color(0xFFFFF59D),
  );
}
