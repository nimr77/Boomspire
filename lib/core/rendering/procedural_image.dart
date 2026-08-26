import 'dart:ui' as ui;

/// Renders a one-off vector drawing to a cached raster [ui.Image].
///
/// Used to build our 2D art (towers, soldiers, terrain) procedurally so the
/// prototype ships with original, license-free "sprites" instead of raw
/// per-frame canvas.drawX calls.
Future<ui.Image> renderToImage(
  int width,
  int height,
  void Function(ui.Canvas canvas) paint,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  paint(canvas);
  final picture = recorder.endRecording();
  return picture.toImage(width, height);
}
