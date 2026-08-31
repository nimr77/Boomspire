import 'dart:ui';

import 'package:flame/components.dart';

/// Paints a home base's damage-pulse ring and HP bar - shared by
/// `HomeBaseComponent` (the player's base) and `AiHomeBaseComponent`.
void paintHomeBase(
  Canvas canvas, {
  required Vector2 size,
  required double pulse,
  required double healthRatio,
  required Color ownerColor,
}) {
  if (pulse > 0) {
    final radius = size.x * (0.55 + (1 - pulse) * 0.55);
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFFE53935).withValues(alpha: pulse * 0.85),
    );
  }

  final barWidth = size.x * 0.9;
  final barX = (size.x - barWidth) / 2;
  const barY = -12.0;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(barX, barY, barWidth, 6),
      const Radius.circular(3),
    ),
    Paint()..color = const Color(0xAA000000),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(barX, barY, barWidth * healthRatio, 6),
      const Radius.circular(3),
    ),
    Paint()..color = healthRatio > 0.4 ? ownerColor : const Color(0xFFE53935),
  );
}
