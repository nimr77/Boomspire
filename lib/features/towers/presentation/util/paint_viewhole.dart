import 'package:flutter/material.dart';

/// A small crew vision-slit with a glass glint, reused by every turret so
/// each unit reads as crewed/piloted hardware rather than a bare emitter.
void paintViewhole(Canvas canvas, Offset center) {
  final slit = Rect.fromCenter(center: center, width: 6, height: 3);
  canvas.drawRRect(
    RRect.fromRectAndRadius(slit, const Radius.circular(1.2)),
    Paint()..color = const Color(0xFF0d2b33),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: slit.center.translate(-1.2, -0.6),
        width: 2.2,
        height: 1.2,
      ),
      const Radius.circular(0.6),
    ),
    Paint()..color = const Color(0xCCBEEFFF),
  );
}
