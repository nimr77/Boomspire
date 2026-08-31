import 'package:flutter/material.dart';

/// Apache/Black Hawk-style attack-helicopter gunship - a tapered,
/// pointed-nose fuselage, a chin gun turret, stepped tandem canopy
/// glazing, belly weapon-pylon pods, and an upswept tail stabilizer fin
/// alongside the tail rotor, so it reads as an armed gunship rather than a
/// civilian-looking helicopter.
void paintHelicopter(Canvas canvas) {
  const size = 46.0;
  const center = Offset(size / 2, size / 2);

  canvas.drawOval(
    Rect.fromCenter(center: center, width: size * 0.92, height: size * 0.28),
    Paint()..color = const Color(0x40000000),
  );

  // Tail boom, thinning toward the tail rotor.
  final boomPath = Path()
    ..moveTo(center.dx - size * 0.08, center.dy - size * 0.09)
    ..lineTo(center.dx - size * 0.48, center.dy - size * 0.03)
    ..lineTo(center.dx - size * 0.48, center.dy + size * 0.04)
    ..lineTo(center.dx - size * 0.08, center.dy + size * 0.1)
    ..close();
  canvas.drawPath(boomPath, Paint()..color = const Color(0xFF33383C));

  // Upswept tail stabilizer fin - the gunship silhouette cue absent from
  // the old design.
  final finPath = Path()
    ..moveTo(center.dx - size * 0.46, center.dy - size * 0.02)
    ..lineTo(center.dx - size * 0.58, center.dy - size * 0.2)
    ..lineTo(center.dx - size * 0.36, center.dy - size * 0.04)
    ..close();
  canvas.drawPath(finPath, Paint()..color = const Color(0xFF1A1C20));

  // Tail-rotor blur disc.
  canvas.drawCircle(
    center.translate(-size * 0.5, -size * 0.02),
    size * 0.09,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0x99B0BEC5),
  );

  // Fuselage - tapered, pointed nose instead of a plain rounded rect.
  final bodyPath = Path()
    ..moveTo(center.dx + size * 0.44, center.dy)
    ..lineTo(center.dx + size * 0.2, center.dy - size * 0.14)
    ..lineTo(center.dx - size * 0.18, center.dy - size * 0.15)
    ..lineTo(center.dx - size * 0.2, center.dy - size * 0.02)
    ..lineTo(center.dx - size * 0.2, center.dy + size * 0.1)
    ..lineTo(center.dx - size * 0.1, center.dy + size * 0.16)
    ..lineTo(center.dx + size * 0.2, center.dy + size * 0.14)
    ..close();
  canvas.drawPath(
    bodyPath,
    Paint()
      ..shader = LinearGradient(
        colors: const [Color(0xFF5A6560), Color(0xFF20262A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bodyPath.getBounds()),
  );

  // Engine housing hump on the upper rear deck, with an exhaust port.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(-size * 0.08, -size * 0.2),
        width: size * 0.24,
        height: size * 0.1,
      ),
      const Radius.circular(3),
    ),
    Paint()..color = const Color(0xFF1A1C20),
  );
  canvas.drawCircle(
    center.translate(-size * 0.18, -size * 0.19),
    size * 0.035,
    Paint()..color = const Color(0xFF0D0F10),
  );

  // Stepped tandem canopy (gunner up front/lower, pilot behind/higher) -
  // dark tinted glazing with a small glint, instead of one big glowing
  // bubble.
  final frontCanopy = Rect.fromCenter(
    center: center.translate(size * 0.22, -size * 0.06),
    width: size * 0.16,
    height: size * 0.1,
  );
  final rearCanopy = Rect.fromCenter(
    center: center.translate(size * 0.02, -size * 0.12),
    width: size * 0.16,
    height: size * 0.1,
  );
  for (final canopy in [rearCanopy, frontCanopy]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(canopy, const Radius.circular(2)),
      Paint()..color = const Color(0xFF11151A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(canopy.deflate(1.4), const Radius.circular(1)),
      Paint()..color = const Color(0xFF37474F),
    );
  }
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: frontCanopy.center.translate(-frontCanopy.width * 0.2, -1),
        width: frontCanopy.width * 0.3,
        height: frontCanopy.height * 0.4,
      ),
      const Radius.circular(1),
    ),
    Paint()..color = const Color(0x99FFFFFF),
  );

  // Chin-mounted gun turret ball under the nose.
  canvas.drawCircle(
    center.translate(size * 0.3, size * 0.08),
    size * 0.06,
    Paint()..color = const Color(0xFF1A1C20),
  );
  canvas.drawCircle(
    center.translate(size * 0.3, size * 0.08),
    size * 0.035,
    Paint()..color = const Color(0xFF37474F),
  );

  // Belly weapon-pylon pods (rocket/gun pods) hanging beneath the
  // fuselage, ahead of the landing skids.
  for (final dx in [-size * 0.02, size * 0.16]) {
    final pod = Rect.fromCenter(
      center: center.translate(dx, size * 0.16),
      width: size * 0.14,
      height: size * 0.08,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pod, const Radius.circular(2)),
      Paint()..color = const Color(0xFF2B2F33),
    );
    canvas.drawCircle(
      Offset(pod.right, pod.center.dy),
      pod.height * 0.28,
      Paint()..color = const Color(0xFF0D0F10),
    );
  }

  // Landing skids.
  for (final dy in [size * 0.24, size * 0.29]) {
    canvas.drawLine(
      center.translate(-size * 0.14, dy),
      center.translate(size * 0.28, dy),
      Paint()
        ..color = const Color(0xFF1a1c20)
        ..strokeWidth = 1.6,
    );
  }

  // Rotor mast stub - the actual spinning blades are a separate live
  // child component layered on top so they can rotate every frame.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, -size * 0.24),
        width: size * 0.06,
        height: size * 0.14,
      ),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFF1a1c20),
  );
}
