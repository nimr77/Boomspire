import 'dart:math';
import 'dart:ui' as ui;

import 'volcanic_lake_ember_math.dart';
import 'volcanic_lake_pulse_math.dart';

/// Live per-frame magma shimmer for volcanic lakes: a pulsing ambient
/// glow plus rising, fading embers, clipped to [shape] - the pond
/// counterpart to `paintLavaFlowOverlay`.
void paintVolcanicLakeFlowOverlay(
  ui.Canvas canvas,
  ui.Path shape,
  double cellSize,
  double phase,
) {
  final bounds = shape.getBounds();
  if (bounds.width <= 0 || bounds.height <= 0) return;
  canvas.save();
  canvas.clipPath(shape);

  final pulseMetrics = volcanicLakePulse(phase);
  canvas.drawRect(
    bounds,
    ui.Paint()
      ..color = ui.Color.lerp(
        const ui.Color(0xFFff7a1a),
        const ui.Color(0xFFffe066),
        pulseMetrics.value,
      )!.withValues(alpha: pulseMetrics.alpha)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10),
  );

  final rnd = Random(41);
  final emberCount =
      ((bounds.width * bounds.height) / (cellSize * cellSize * 3))
          .round()
          .clamp(6, 40);
  for (var i = 0; i < emberCount; i++) {
    final baseX = bounds.left + rnd.nextDouble() * bounds.width;
    final baseY = bounds.top + rnd.nextDouble() * bounds.height;
    // Fade in then out, so nothing pops in/out at full brightness.
    final ember = volcanicLakeEmberMetrics(
      index: i,
      phase: phase,
      baseY: baseY,
    );
    canvas.drawCircle(
      ui.Offset(baseX, ember.y),
      1.2 + rnd.nextDouble() * 1.3,
      ui.Paint()
        ..color = const ui.Color(0xFFffcf7a)
            .withValues(alpha: ember.alpha * 0.75),
    );
  }

  canvas.restore();
}
