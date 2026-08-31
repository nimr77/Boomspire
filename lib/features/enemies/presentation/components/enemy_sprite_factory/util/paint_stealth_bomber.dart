import 'package:flutter/material.dart';

/// Same neutral stealth-gray livery as `AllySpriteFactory`'s stealth
/// bomber paint routine - team ownership is shown by
/// `TeamStripeMarkerComponent` instead.
void paintStealthBomber(Canvas canvas) {
  const size = 54.0;
  const center = Offset(size / 2, size / 2);

  final wingPath = Path()
    ..moveTo(center.dx, center.dy - size * 0.12)
    ..lineTo(center.dx + size * 0.48, center.dy + size * 0.34)
    ..lineTo(center.dx + size * 0.3, center.dy + size * 0.4)
    ..lineTo(center.dx, center.dy + size * 0.16)
    ..lineTo(center.dx - size * 0.3, center.dy + size * 0.4)
    ..lineTo(center.dx - size * 0.48, center.dy + size * 0.34)
    ..close();
  canvas.drawPath(
    wingPath,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3A3F44), Color(0xFF0D0F10)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: size * 0.4)),
  );
  canvas.drawPath(
    wingPath,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0x33000000),
  );

  canvas.drawOval(
    Rect.fromCenter(
      center: center.translate(0, -size * 0.02),
      width: size * 0.1,
      height: size * 0.16,
    ),
    Paint()..color = const Color(0xFF1A1C1E),
  );
}
