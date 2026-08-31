import 'dart:math';
import 'dart:ui' as ui;

import '../../../../domain/models/biome.dart';

/// Ground base pass for `TerrainPainter.paint`: the vertical gradient
/// fill, a scattering of soft shaded boulder/patch blobs, then a fine
/// speckle/fleck layer (grass blades, pebbles, sand grains) so the ground
/// reads as a detailed painted tile instead of a flat gradient, RA2-style.
/// Both randomized layers share one continuing random sequence, matching
/// the original single-pass look.
void paintGroundBase(ui.Canvas canvas, ui.Size size, BiomePalette palette) {
  final rect = ui.Offset.zero & size;
  canvas.drawRect(
    rect,
    ui.Paint()
      ..shader = ui.Gradient.linear(
        const ui.Offset(0, 0),
        ui.Offset(0, size.height),
        [palette.groundTop, palette.groundMid, palette.groundBottom],
        const [0.0, 0.5, 1.0],
      ),
  );

  final rnd = Random(42);
  for (var i = 0; i < 260; i++) {
    final x = rnd.nextDouble() * size.width;
    final y = rnd.nextDouble() * size.height;
    final r = 14 + rnd.nextDouble() * 40;
    final shade = 0.15 + rnd.nextDouble() * 0.25;
    final color = ui.Color.lerp(
      palette.groundBottom,
      palette.groundMid,
      shade,
    )!.withValues(alpha: 0.3);
    canvas.drawCircle(
      ui.Offset(x, y),
      r,
      ui.Paint()
        ..color = color
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 14),
    );
  }
  // Fine speckle/fleck layer - small crisp dots (grass blades, pebbles,
  // sand grains) so the ground reads as a detailed painted tile instead
  // of a flat gradient, RA2-style.
  for (var i = 0; i < 900; i++) {
    final x = rnd.nextDouble() * size.width;
    final y = rnd.nextDouble() * size.height;
    final light = rnd.nextBool();
    final color = (light ? palette.ridgeLight : palette.groundBottom)
        .withValues(alpha: 0.12 + rnd.nextDouble() * 0.1);
    canvas.drawRect(
      ui.Rect.fromCenter(
        center: ui.Offset(x, y),
        width: 1.5 + rnd.nextDouble() * 1.5,
        height: 1.5 + rnd.nextDouble() * 1.5,
      ),
      ui.Paint()..color = color,
    );
  }
}
