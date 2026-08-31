import 'package:flutter/material.dart';

import 'ally_livery.dart';

/// Paints the friendly anti-air soldier "2D object model" - a backpack
/// launcher tilted skyward, sharing the home base's cyan livery.
void paintAntiAir(Canvas canvas) {
  const size = 48.0;
  const center = Offset(size / 2, size / 2);
  const weaponAccent = Color(0xFFFFB300);

  canvas.drawOval(
    Rect.fromCenter(
      center: center.translate(0, size * 0.3),
      width: size * 0.5,
      height: size * 0.18,
    ),
    Paint()..color = const Color(0x59000000),
  );

  // Legs - narrow, close-set rectangles directly under the torso instead
  // of a pair of splayed-out ovals (which read as bug legs).
  for (final dx in [-size * 0.075, size * 0.075]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(dx, size * 0.28),
          width: size * 0.1,
          height: size * 0.26,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = kAllyHullDark,
    );
  }

  // Torso - shoulders-wider-than-hips trapezoid, reads as a person
  // instead of a uniform blob.
  final torsoPath = Path()
    ..moveTo(center.dx - size * 0.26, center.dy - size * 0.2)
    ..lineTo(center.dx + size * 0.26, center.dy - size * 0.2)
    ..lineTo(center.dx + size * 0.17, center.dy + size * 0.2)
    ..lineTo(center.dx - size * 0.17, center.dy + size * 0.2)
    ..close();
  canvas.drawPath(
    torsoPath,
    Paint()
      ..shader = const LinearGradient(
        colors: [kAllyHull, kAllyHullDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(torsoPath.getBounds()),
  );
  canvas.drawLine(
    Offset(center.dx, center.dy - size * 0.18),
    Offset(center.dx, center.dy + size * 0.18),
    Paint()
      ..color = weaponAccent.withValues(alpha: 0.7)
      ..strokeWidth = 2,
  );

  // Shoulder pads instead of flanking circles.
  for (final dx in [-size * 0.24, size * 0.24]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(dx, -size * 0.18),
          width: size * 0.13,
          height: size * 0.1,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = kAllyHullDark,
    );
  }

  // Backpack-mounted launcher, tilted skyward.
  final launcher = Paint()
    ..color = const Color(0xFF2b2b2b)
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    center.translate(size * 0.04, -size * 0.12),
    center.translate(size * 0.36, -size * 0.5),
    launcher,
  );
  canvas.drawCircle(
    center.translate(size * 0.36, -size * 0.5),
    size * 0.06,
    Paint()..color = weaponAccent,
  );

  canvas.drawCircle(
    center.translate(0, -size * 0.3),
    size * 0.16,
    Paint()..color = kAllyHullDark,
  );
  canvas.drawCircle(
    center.translate(0, -size * 0.32),
    size * 0.14,
    Paint()..color = kAllyHull,
  );
  final visorRect = Rect.fromCenter(
    center: center.translate(0, -size * 0.3),
    width: size * 0.22,
    height: size * 0.05,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(visorRect, const Radius.circular(2)),
    Paint()..color = const Color(0xFF0d1a1e),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: visorRect.center.translate(-visorRect.width * 0.22, -0.6),
        width: visorRect.width * 0.32,
        height: visorRect.height * 0.5,
      ),
      const Radius.circular(1),
    ),
    Paint()..color = weaponAccent.withValues(alpha: 0.9),
  );
}
