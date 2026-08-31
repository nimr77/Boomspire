import 'package:flutter/material.dart';

/// Paints the enemy artillery-barrage vehicle "2D object model" - three
/// stubby mortar barrels fanned out on a deck plate.
void paintArtilleryBarrage(Canvas canvas) {
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
          center: center.translate(dx, size * 0.08),
          width: size * 0.14,
          height: size * 0.58,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF1a1c20),
    );
  }

  final hullRect = Rect.fromCenter(
    center: center,
    width: size * 0.6,
    height: size * 0.4,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(hullRect, const Radius.circular(6)),
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5D4037), Color(0xFF2E1A16)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(hullRect),
  );

  // Mortar deck - a mounting plate the barrels visibly sit on, instead
  // of bare tubes sprouting straight off the hull like antennae.
  final deckRect = Rect.fromCenter(
    center: center.translate(0, -size * 0.16),
    width: size * 0.5,
    height: size * 0.16,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(deckRect, const Radius.circular(3)),
    Paint()..color = const Color(0xFF3E2723),
  );

  // Three stubby mortar barrels fanned out on the deck.
  for (final dx in [-size * 0.14, 0.0, size * 0.14]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(dx, -size * 0.24),
          width: size * 0.1,
          height: size * 0.22,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF3E2723),
    );
  }
  canvas.drawCircle(
    center.translate(0, size * 0.02),
    size * 0.05,
    Paint()..color = const Color(0xFFE53935),
  );
}
