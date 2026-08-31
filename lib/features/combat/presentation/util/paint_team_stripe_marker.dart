import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Paints `TeamStripeMarkerComponent`'s pulsing team-color glow light.
void paintTeamStripeMarker(
  Canvas canvas, {
  required Vector2 size,
  required Color accent,
  required double phase,
}) {
  final pulse = 0.5 + 0.5 * sin(phase);
  final center = Offset(size.x / 2, size.y / 2);
  final radius = size.x * 0.5;

  canvas.drawCircle(
    center,
    radius * (1.3 + pulse * 0.4),
    Paint()
      ..color = accent.withValues(alpha: 0.2 + pulse * 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.6),
  );
  canvas.drawCircle(
    center,
    radius * (0.7 + pulse * 0.3),
    Paint()..color = accent.withValues(alpha: 0.75 + pulse * 0.25),
  );
}
