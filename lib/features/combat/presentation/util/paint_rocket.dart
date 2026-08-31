import 'dart:ui';

import 'package:flame/components.dart';

/// Paints `RocketComponent`'s body + nose tip.
void paintRocket(
  Canvas canvas, {
  required Vector2 size,
  required Color bodyColor,
  required Color tipColor,
}) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(2),
    ),
    Paint()..color = bodyColor,
  );
  canvas.drawCircle(
    Offset(size.x - 2, size.y / 2),
    2.6,
    Paint()..color = tipColor,
  );
}
