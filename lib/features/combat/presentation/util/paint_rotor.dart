import 'dart:ui';

import 'package:flame/components.dart';

/// Paints `RotorComponent`'s spinning blade blur plus hub.
void paintRotor(Canvas canvas, {required Vector2 size, required double spin}) {
  final center = size / 2;
  canvas.save();
  canvas.translate(center.x, center.y);
  canvas.rotate(spin);
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y * 0.1),
    Paint()..color = const Color(0x66B0BEC5),
  );
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: size.x * 0.1, height: size.y),
    Paint()..color = const Color(0x66B0BEC5),
  );
  canvas.restore();
  canvas.drawCircle(
    Offset(center.x, center.y),
    size.x * 0.04,
    Paint()..color = const Color(0xFF1a1c20),
  );
}
