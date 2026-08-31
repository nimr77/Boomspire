import 'dart:ui';

import 'package:flame/components.dart';

/// Paints `VehicleTreadComponent`'s scrolling row of tread/wheel dashes.
void paintVehicleTread(
  Canvas canvas, {
  required Vector2 size,
  required double scroll,
}) {
  const dashCount = 4;
  final spacing = size.x / dashCount;
  final dashWidth = spacing * 0.55;
  final paint = Paint()..color = const Color(0xFF17191C);
  // Local render coords run 0..size (top-left origin), so the vertical
  // center of the dash strip is size.y / 2, not 0.
  for (var i = 0; i < dashCount; i++) {
    final x = (i * spacing + scroll) % size.x;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, size.y / 2),
          width: dashWidth,
          height: size.y,
        ),
        const Radius.circular(2),
      ),
      paint,
    );
  }
}
