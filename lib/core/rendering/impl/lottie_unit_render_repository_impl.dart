import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame_lottie/flame_lottie.dart' as flottie;
import 'package:flutter/services.dart' show rootBundle;

import '../domain/repos/unit_render_repository.dart';
import '../procedural_image.dart' show kSpriteSupersample;

/// Script-authored `.json` (Lottie/Bodymovin) backend (see
/// `tool/lottie_gen/`).
///
/// The generated files under `assets/models/` are static, single-frame
/// compositions - all per-frame motion (bobbing, rotor spin, recoil) stays
/// owned by Flame, not the Lottie timeline. So rather than mounting a live
/// `LottieComponent` (which re-walks and repaints the whole vector shape
/// tree every frame, for every on-screen instance - expensive once dozens
/// of units share the screen), this backend rasterizes the composition to
/// a `ui.Image` ONCE per [key] and reuses that cached image for every
/// instance after that, exactly like the existing procedural sprites'
/// `renderToImage` caching. Runtime cost per instance is then identical to
/// a plain `SpriteComponent`.
class LottieUnitRenderRepositoryImpl implements UnitRenderRepository {
  static final Map<String, ui.Image> _cache = {};

  @override
  Future<PositionComponent> render({
    required String key,
    required Vector2 size,
    required Future<PositionComponent> Function() fallback,
  }) async {
    final path = 'assets/models/$key.json';
    if (await _assetExists(path)) {
      try {
        final image = _cache[key] ?? await _bake(path);
        _cache[key] = image;
        return SpriteComponent(
          sprite: Sprite(image),
          size: size,
          anchor: Anchor.center,
          position: size / 2,
        );
      } catch (_) {
        _cache.remove(key);
        // Fall through - no valid/renderable Lottie asset for this key.
      }
    }
    return fallback();
  }

  Future<ui.Image> _bake(String path) async {
    final composition = await flottie.loadLottie(flottie.Lottie.asset(path));
    final drawable = flottie.LottieDrawable(composition)..setProgress(0);
    final width = composition.bounds.width;
    final height = composition.bounds.height;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.scale(kSpriteSupersample.toDouble());
    drawable.draw(
      canvas,
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    );
    final picture = recorder.endRecording();
    return picture.toImage(
      width * kSpriteSupersample,
      height * kSpriteSupersample,
    );
  }

  static Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }
}
