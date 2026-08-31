import 'package:flutter/material.dart';

import 'ally_livery.dart';

/// Paints the friendly drone "2D object model" - a small straight-wing UAV
/// silhouette (Reaper/Predator-style) with long high-aspect wings and a
/// V-tail instead of the delta wings shared by [paintAircraft]/attack-plane
/// kinds, so it reads as a distinct, cheap drone rather than a smaller
/// fighter jet. Flies the exact same strafing-run AI as the other
/// plane-body kinds (see `UnitKind.drone.bodyType`).
void paintDrone(Canvas canvas) {
  const size = 42.0;
  const center = Offset(size / 2, size / 2);

  canvas.drawOval(
    Rect.fromCenter(center: center, width: size * 0.5, height: size * 0.7),
    Paint()..color = const Color(0x33000000),
  );

  // Long straight wings.
  final wingRect = Rect.fromCenter(
    center: center,
    width: size * 0.86,
    height: size * 0.12,
  );
  canvas.drawRect(
    wingRect,
    Paint()
      ..shader = const LinearGradient(
        colors: [kAllyHull, kAllyHullDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(wingRect),
  );
  canvas.drawRect(
    wingRect,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = kAllyAccent.withValues(alpha: 0.7),
  );

  // Slender fuselage running nose-to-tail.
  final fuselageRect = Rect.fromCenter(
    center: center,
    width: size * 0.16,
    height: size * 0.78,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(fuselageRect, const Radius.circular(6)),
    Paint()
      ..shader = const LinearGradient(
        colors: [kAllyHull, kAllyHullDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(fuselageRect),
  );

  // Inverted V-tail.
  final tailPath = Path()
    ..moveTo(center.dx, center.dy + size * 0.3)
    ..lineTo(center.dx - size * 0.16, center.dy + size * 0.39)
    ..lineTo(center.dx - size * 0.05, center.dy + size * 0.3)
    ..close()
    ..moveTo(center.dx, center.dy + size * 0.3)
    ..lineTo(center.dx + size * 0.16, center.dy + size * 0.39)
    ..lineTo(center.dx + size * 0.05, center.dy + size * 0.3)
    ..close();
  canvas.drawPath(tailPath, Paint()..color = kAllyHullDark);

  // Sensor ball under the nose.
  canvas.drawCircle(
    center.translate(0, -size * 0.34),
    size * 0.07,
    Paint()..color = const Color(0xFF1a1c20),
  );
  canvas.drawCircle(
    center.translate(0, -size * 0.34),
    size * 0.045,
    Paint()..color = kAllyAccent.withValues(alpha: 0.9),
  );

  // Pusher-prop hub at the tail.
  canvas.drawCircle(
    center.translate(0, size * 0.36),
    size * 0.05,
    Paint()..color = const Color(0xFF1a1c20),
  );
}
