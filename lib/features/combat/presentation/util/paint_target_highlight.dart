import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Paints `TargetHighlightComponent`'s breathing target-lock tint.
void paintTargetHighlight(
  Canvas canvas, {
  required Vector2 size,
  required Color color,
  required double timer,
  required double fadeDuration,
  required double baseAlpha,
  required double pulsePhase,
}) {
  if (timer <= 0) return;
  final ratio = timer / fadeDuration;
  // A slow breathing pulse on top of the fade so a sustained lock (which
  // re-triggers every frame while in range) still reads as "alive"
  // instead of a static flat tint.
  final pulse = 0.5 + 0.5 * sin(pulsePhase);
  canvas.drawCircle(
    Offset(size.x / 2, size.y / 2),
    size.x * (0.5 + pulse * 0.08),
    Paint()
      ..color = color.withValues(alpha: baseAlpha * ratio * (0.6 + pulse * 0.4))
      ..blendMode = BlendMode.srcATop,
  );
}
