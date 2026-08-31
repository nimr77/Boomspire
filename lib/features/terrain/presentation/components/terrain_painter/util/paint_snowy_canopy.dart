import 'dart:math';
import 'dart:ui' as ui;

import 'paint_round_canopy.dart';

/// Same rounded canopy as the default tree, but frosted with a snow cap
/// on top - the tundra's trees stay green under a dusting of snow rather
/// than turning into conifers.
void paintSnowyCanopy(ui.Canvas canvas, double cx, double cy, double scale) {
  paintRoundCanopy(canvas, cx, cy, scale);
  canvas.drawArc(
    ui.Rect.fromCenter(
      center: ui.Offset(cx, cy - 8 * scale),
      width: 20 * scale,
      height: 16 * scale,
    ),
    pi,
    pi,
    false,
    ui.Paint()..color = const ui.Color(0xFFFFFFFF).withValues(alpha: 0.75),
  );
}
