import 'dart:ui' as ui;

import 'autumn_leaf_colors.dart';

/// Paints a single tumbling autumn leaf, rotated in place.
void paintAutumnLeafParticle(
  ui.Canvas canvas, {
  required double x,
  required double y,
  required double scale,
  required double opacity,
  required double rotation,
  required int colorIndex,
}) {
  final leafSize = 5 * scale;
  canvas.save();
  canvas.translate(x, y);
  canvas.rotate(rotation);
  canvas.drawOval(
    ui.Rect.fromCenter(
      center: ui.Offset.zero,
      width: leafSize * 2,
      height: leafSize,
    ),
    ui.Paint()
      ..color = kAutumnLeafColors[colorIndex].withValues(alpha: opacity),
  );
  canvas.restore();
}
