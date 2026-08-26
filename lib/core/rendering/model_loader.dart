import 'package:flame/components.dart';
import 'package:flame_lottie/flame_lottie.dart' as flottie;
import 'package:flame_rive/flame_rive.dart' as frive;
import 'package:flutter/services.dart' show rootBundle;

/// Optional external "model" loader for units/towers.
///
/// This game's art is otherwise procedural (drawn on canvas - see
/// `core/rendering/procedural_image.dart`), since this dev environment has
/// no way to download binary art assets from the internet. This loader is
/// the seam for real, hand-authored models: drop a `<key>.riv` (Rive) or
/// `<key>.json` (Lottie) file into `assets/models/` and it is picked up
/// automatically here - no other code changes required. Until such a file
/// exists for a given [key], [fallback] (the current procedural sprite) is
/// used, so nothing changes visually today.
class ModelLoader {
  const ModelLoader._();

  static Future<PositionComponent> loadOrFallback({
    required String key,
    required Vector2 size,
    required Future<PositionComponent> Function() fallback,
  }) async {
    final rivePath = 'assets/models/$key.riv';
    if (await _assetExists(rivePath)) {
      try {
        await frive.RiveNative.init();
        final file = await frive.File.asset(
          rivePath,
          riveFactory: frive.Factory.flutter,
        );
        if (file != null) {
          final artboard = await frive.loadArtboard(file);
          return frive.RiveComponent(artboard: artboard, size: size);
        }
      } catch (_) {
        // Fall through to the Lottie/procedural fallback below.
      }
    }

    final lottiePath = 'assets/models/$key.json';
    if (await _assetExists(lottiePath)) {
      try {
        final composition = await flottie.loadLottie(
          flottie.Lottie.asset(lottiePath),
        );
        return flottie.LottieComponent(
          composition,
          size: size,
          repeating: true,
        );
      } catch (_) {
        // Fall through to the procedural fallback below.
      }
    }

    return fallback();
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
