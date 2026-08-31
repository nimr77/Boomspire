import 'dart:ui' as ui;

/// Blits the terrain's baked base image (rendered at a supersampled
/// resolution purely for source detail) scaled back down to the
/// component's logical size.
void paintBaseImage(
  ui.Canvas canvas,
  ui.Image image, {
  required double width,
  required double height,
}) {
  canvas.drawImageRect(
    image,
    ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    ui.Rect.fromLTWH(0, 0, width, height),
    ui.Paint()..filterQuality = ui.FilterQuality.medium,
  );
}
