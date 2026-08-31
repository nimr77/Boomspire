import 'package:flutter/material.dart';

/// A low barracks building with a peaked roof, door and windows - reads
/// as a muster point rather than a gun emplacement.
void paintTrainingCenterBase(Canvas canvas) {
  const accent = Color(0xFF66BB6A);
  final body = RRect.fromRectAndRadius(
    const Rect.fromLTWH(10, 28, 44, 28),
    const Radius.circular(4),
  );
  canvas.drawShadow(Path()..addRRect(body), const Color(0xFF000000), 4, false);
  canvas.drawRRect(
    body,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4c7a4f), Color(0xFF20242a)],
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

  final roof = Path()
    ..moveTo(6, 28)
    ..lineTo(32, 9)
    ..lineTo(58, 28)
    ..close();
  canvas.drawPath(roof, Paint()..color = const Color(0xFF2f4a31));
  canvas.drawPath(
    roof,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = accent,
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(27, 40, 10, 16),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFF11151a),
  );
  for (final dx in [-14.0, 14.0]) {
    final window = Rect.fromCenter(
      center: Offset(32 + dx, 37),
      width: 8,
      height: 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(window, const Radius.circular(1.5)),
      Paint()..color = const Color(0xFF11151a),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(window, const Radius.circular(1.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = accent,
    );
  }
}
