import 'package:flutter/material.dart';

/// Paints the enemy soldier "2D object model" - a green rifleman, or (when
/// [heavy]) a bulkier, red-trimmed heavy soldier.
void paintEnemySoldier(Canvas canvas, {required bool heavy}) {
  final size = heavy ? 60.0 : 48.0;
  final center = Offset(size / 2, size / 2);
  final bodyColor = heavy ? const Color(0xFF33691E) : const Color(0xFF4C7A2A);
  final darkColor = heavy ? const Color(0xFF1B3D0F) : const Color(0xFF2E4B18);

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
      Paint()..color = darkColor,
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
      ..shader = LinearGradient(
        colors: [bodyColor, darkColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(torsoPath.getBounds()),
  );
  if (heavy) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, size * 0.02),
          width: size * 0.22,
          height: size * 0.24,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF263A17),
    );
  }
  canvas.drawLine(
    Offset(center.dx, center.dy - size * 0.18),
    Offset(center.dx, center.dy + size * 0.18),
    Paint()
      ..color = darkColor
      ..strokeWidth = 2,
  );

  // Shoulder pads - rectangular armor plates instead of round dots (round
  // "spots" on a rounded green body read as insect markings).
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
      Paint()..color = heavy ? const Color(0xFFB71C1C) : darkColor,
    );
  }

  // Rifle - shouldered, angled forward from near one shoulder instead of
  // slicing across the whole body like a stray limb.
  final riflePaint = Paint()
    ..color = const Color(0xFF1a1a1a)
    ..strokeWidth = heavy ? 4 : 3
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    center.translate(size * 0.14, -size * 0.12),
    center.translate(size * 0.34, -size * 0.46),
    riflePaint,
  );

  canvas.drawCircle(
    center.translate(0, -size * 0.3),
    size * 0.17,
    Paint()..color = darkColor,
  );
  canvas.drawCircle(
    center.translate(0, -size * 0.32),
    size * 0.15,
    Paint()..color = bodyColor,
  );
  // Visor viewhole - a dark slit with a glass glint so the face reads at
  // a glance, instead of a flat helmet color block.
  final visorRect = Rect.fromCenter(
    center: center.translate(0, -size * 0.3),
    width: size * 0.22,
    height: size * 0.05,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(visorRect, const Radius.circular(2)),
    Paint()..color = const Color(0xFF0d1a06),
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
    Paint()..color = const Color(0xCCBEEFFF),
  );
}
