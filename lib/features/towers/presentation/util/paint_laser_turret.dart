import 'package:flutter/material.dart';

import 'paint_viewhole.dart';

/// A single slender emitter rod ending in a crystal lens - reads as an
/// energy weapon rather than a ballistic one.
void paintLaserTurret(Canvas canvas, Offset center) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -12), width: 6, height: 26),
      const Radius.circular(3),
    ),
    Paint()
      ..shader =
          const LinearGradient(colors: [Color(0xFF3a1030), Color(0xFF120810)])
              .createShader(
                Rect.fromCenter(
                  center: center.translate(0, -12),
                  width: 6,
                  height: 26,
                ),
              ),
  );
  for (final r in [7.0, 4.0]) {
    canvas.drawCircle(
      center.translate(0, -24),
      r,
      Paint()
        ..color = const Color(0xFFFF3D9A)
            .withValues(alpha: r == 7.0 ? 0.35 : 0.9)
        ..maskFilter = r == 7.0
            ? const MaskFilter.blur(BlurStyle.normal, 4)
            : null,
    );
  }
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF7a2a55), Color(0xFF2b2f36)],
      ).createShader(Rect.fromCircle(center: center, radius: 12)),
  );
  canvas.drawCircle(
    center,
    12,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFF3D9A),
  );
  paintViewhole(canvas, center.translate(-6, 6));
}
