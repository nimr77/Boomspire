import 'package:flutter/material.dart';

/// Small straight-wing UAV silhouette (Reaper/Predator-style) - long
/// high-aspect wings and a V-tail instead of the delta wings shared by
/// [paintAttackPlane], so it reads as a distinct, cheap drone rather than a
/// smaller fighter jet.
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
        colors: [Color(0xFF9E9D7D), Color(0xFF44432E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(wingRect),
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
        colors: [Color(0xFF9E9D7D), Color(0xFF33321F)],
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
  canvas.drawPath(tailPath, Paint()..color = const Color(0xFF33321F));

  // Sensor ball under the nose (red - hostile).
  canvas.drawCircle(
    center.translate(0, -size * 0.34),
    size * 0.07,
    Paint()..color = const Color(0xFF1a1c20),
  );
  canvas.drawCircle(
    center.translate(0, -size * 0.34),
    size * 0.045,
    Paint()..color = const Color(0xFFE53935),
  );

  // Pusher-prop hub at the tail.
  canvas.drawCircle(
    center.translate(0, size * 0.36),
    size * 0.05,
    Paint()..color = const Color(0xFF1a1c20),
  );
}
