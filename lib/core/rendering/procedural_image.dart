import 'dart:ui' as ui;

/// Renders every procedural sprite at this multiple of its requested
/// logical size before handing it to Flame - since [Sprite]/[SpriteComponent]
/// always draw the image scaled to fit the component's `size` regardless of
/// the source image's actual pixel dimensions, this just gives Skia more
/// source detail to downsample from, which reads as far less "pixelated"
/// once a tower/enemy is scaled up (upgrades, zoom, etc).
const int kSpriteSupersample = 3;

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
  canvas.scale(kSpriteSupersample.toDouble());
  paint(canvas);
  final picture = recorder.endRecording();
  return picture.toImage(
    width * kSpriteSupersample,
    height * kSpriteSupersample,
  );
}
