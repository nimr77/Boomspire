import 'package:flutter/material.dart';

/// Paints the minimap's team-coloured entity dots plus the camera
/// viewport outline - used by `GameCoreMinimapPainter`.
void paintMinimap(
  Canvas canvas, {
  required List<({Offset point, Color color, double radius})> dots,
  required Rect cameraRect,
}) {
  for (final dot in dots) {
    canvas.drawCircle(dot.point, dot.radius, Paint()..color = dot.color);
  }
  canvas.drawRect(
    cameraRect,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = Colors.white,
  );
}
