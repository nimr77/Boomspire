import 'dart:math' as math;
import 'dart:ui' as ui;

import 'sky_flame_metrics.dart';

/// Blurred orange/gold glow blobs drifting near the top edge, like distant
/// wildfire/volcanic flame lighting up the sky - shown whenever the
/// resolved wind type is ash, independent of wind strength (a still-air
/// ash scene still has the fire glowing behind it).
void paintSkyFlames(
  ui.Canvas canvas, {
  required double width,
  required double height,
  required double weatherPhase,
}) {
  final rnd = math.Random(21);
  for (var i = 0; i < 6; i++) {
    final flame = skyFlameMetrics(
      index: i,
      randX: rnd.nextDouble(),
      randBaseY: rnd.nextDouble(),
      randFrequency: rnd.nextDouble(),
      randRadius: rnd.nextDouble(),
      randColor: rnd.nextDouble(),
      width: width,
      height: height,
      weatherPhase: weatherPhase,
    );
    canvas.drawCircle(
      ui.Offset(flame.x, flame.y),
      flame.radius,
      ui.Paint()
        ..color = ui.Color.lerp(
          const ui.Color(0xFFFF6D1F),
          const ui.Color(0xFFFFC107),
          flame.colorT,
        )!.withValues(alpha: flame.alpha)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 20),
    );
  }
}
