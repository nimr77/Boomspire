import 'dart:ui';

import 'package:flame/components.dart';

/// Paints one frame of an `ImpactSparkComponent`'s spark lines at
/// animation progress [t] (0..1).
void paintImpactSparks(
  Canvas canvas, {
  required double t,
  required Color color,
  required List<Vector2> sparks,
}) {
  final paint = Paint()
    ..color = color.withValues(alpha: (1 - t) * 0.9)
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  for (final spark in sparks) {
    final p = spark * t;
    canvas.drawLine(Offset(p.x, p.y), Offset(p.x * 0.5, p.y * 0.5), paint);
  }
}
