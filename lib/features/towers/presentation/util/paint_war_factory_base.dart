import 'package:flutter/material.dart';

/// A wide corrugated workshop with a roll-up bay door - reads as heavy
/// industry rather than a gun emplacement.
void paintWarFactoryBase(Canvas canvas) {
  const accent = Color(0xFFB0BEC5);
  final body = RRect.fromRectAndRadius(
    const Rect.fromLTWH(6, 26, 52, 30),
    const Radius.circular(3),
  );
  canvas.drawShadow(Path()..addRRect(body), const Color(0xFF000000), 4, false);
  canvas.drawRRect(
    body,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF607d8b), Color(0xFF20242a)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(body.outerRect),
  );
  canvas.drawRRect(
    body,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = accent.withValues(alpha: 0.85),
  );

  for (var x = 12.0; x <= 52; x += 8) {
    canvas.drawLine(
      Offset(x, 26),
      Offset(x, 19),
      Paint()
        ..color = const Color(0xFF37474F)
        ..strokeWidth = 2,
    );
  }

  const door = Rect.fromLTWH(22, 40, 20, 16);
  canvas.drawRRect(
    RRect.fromRectAndRadius(door, const Radius.circular(2)),
    Paint()..color = const Color(0xFF11151a),
  );
  for (var y = door.top + 3; y < door.bottom; y += 4) {
    canvas.drawLine(
      Offset(door.left + 2, y),
      Offset(door.right - 2, y),
      Paint()
        ..color = accent.withValues(alpha: 0.5)
        ..strokeWidth = 1,
    );
  }
}
