import 'dart:ui';

import 'package:flame/components.dart';

/// Paints `VehiclePlayerMarkerComponent`'s static team-color roundel.
void paintVehiclePlayerMarker(
  Canvas canvas, {
  required Vector2 size,
  required Color accent,
}) {
  final center = Offset(size.x / 2, size.y / 2);
  final radius = size.x / 2;
  canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF2B2E33));
  canvas.drawCircle(center, radius * 0.68, Paint()..color = accent);
}
