import 'dart:ui' as ui;

import '../../../../domain/models/biome.dart';

/// Static shore/bed/water-gradient layers only - baked once into the
/// cached terrain image. The moving shimmer/ripples are drawn separately
/// every frame by `TerrainPainter.paintRiverFlow` so the river reads as
/// flowing water.
void paintRiverBed(
  ui.Canvas canvas,
  ui.Path path,
  double cellSize,
  BiomePalette palette,
) {
  final bounds = path.getBounds();
  // Sandy shore first, wider than the water itself - tinted by the
  // river's brush type (e.g. a frozen-variant river gets a pale, icy
  // shore instead of the default warm sand).
  canvas.drawPath(
    path,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..strokeWidth = cellSize * 2.0
      ..color = ui.Color.lerp(
        const ui.Color(0xFFd8c48a),
        palette.groundMid,
        0.4,
      )!.withValues(alpha: 0.55),
  );
  // Wet, darker sand right at the waterline.
  canvas.drawPath(
    path,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..strokeWidth = cellSize * 1.5
      ..color = ui.Color.lerp(
        const ui.Color(0xFF9c8256),
        palette.groundBottom,
        0.4,
      )!.withValues(alpha: 0.6),
  );
  // Soft blurred glow beneath the crisp water fill for depth, so the
  // channel doesn't read as a flat stripe.
  canvas.drawPath(
    path,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..strokeWidth = cellSize * 1.5
      ..color = ui.Color.lerp(
        const ui.Color(0xFF0d4a68),
        palette.capColor,
        0.2,
      )!.withValues(alpha: 0.35)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5),
  );
  // Water body with a deep-to-mid gradient across its width, tinted
  // toward the brush type's cap color (icy pale for snow/frozen, murky
  // for desert, etc.) - richer teal/turquoise stops for a more natural
  // liquid color than a flat blue.
  canvas.drawPath(
    path,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..strokeWidth = cellSize * 1.3
      ..shader = ui.Gradient.linear(
        bounds.topCenter,
        bounds.bottomCenter,
        [
          for (final c in const [
            ui.Color(0xFF0a3450),
            ui.Color(0xFF1c8a9e),
            ui.Color(0xFF0a3450),
            ui.Color(0xFF1c8a9e),
            ui.Color(0xFF0a3450),
          ])
            ui.Color.lerp(c, palette.capColor, 0.22)!,
        ],
        const [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
  );
  // Thin bright glassy glint down the middle, like light catching a
  // gently rippled surface.
  canvas.drawPath(
    path,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..strokeWidth = cellSize * 0.22
      ..color = const ui.Color(0xFFdcfbff).withValues(alpha: 0.09)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2),
  );
}
