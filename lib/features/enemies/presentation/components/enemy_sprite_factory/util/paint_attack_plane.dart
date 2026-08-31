import 'package:flutter/material.dart';

/// Paints the enemy attack-plane "2D object model" - delta wings, a
/// tinted canopy, twin afterburner glows.
void paintAttackPlane(Canvas canvas) {
  const size = 50.0;
  const center = Offset(size / 2, size / 2);

  canvas.drawOval(
    Rect.fromCenter(center: center, width: size * 0.7, height: size * 0.22),
    Paint()..color = const Color(0x40000000),
  );

  // Delta wings - a single sweeping F-35-ish silhouette.
  final wingPath = Path()
    ..moveTo(center.dx, center.dy - size * 0.4)
    ..lineTo(center.dx + size * 0.46, center.dy + size * 0.34)
    ..lineTo(center.dx + size * 0.1, center.dy + size * 0.2)
    ..lineTo(center.dx, center.dy + size * 0.4)
    ..lineTo(center.dx - size * 0.1, center.dy + size * 0.2)
    ..lineTo(center.dx - size * 0.46, center.dy + size * 0.34)
    ..close();
  canvas.drawPath(
    wingPath,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB0BEC5), Color(0xFF37474F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: size * 0.4)),
  );

  // Canopy.
  canvas.drawOval(
    Rect.fromCenter(
      center: center.translate(0, -size * 0.06),
      width: size * 0.13,
      height: size * 0.28,
    ),
    Paint()..color = const Color(0xFF1a1c20),
  );
  canvas.drawOval(
    Rect.fromCenter(
      center: center.translate(0, -size * 0.1),
      width: size * 0.08,
      height: size * 0.14,
    ),
    Paint()..color = const Color(0xCC00E5FF),
  );

  // Twin engine afterburner glow at the tail - reads as "fast/hostile".
  for (final dx in [-size * 0.12, size * 0.12]) {
    canvas.drawCircle(
      center.translate(dx, size * 0.36),
      size * 0.07,
      Paint()
        ..color = const Color(0xFFFF7043)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      center.translate(dx, size * 0.36),
      size * 0.035,
      Paint()..color = const Color(0xFFFFF3C4),
    );
  }
}
