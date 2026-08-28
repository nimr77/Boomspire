import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart' as frive;
import 'package:flutter/services.dart' show rootBundle;

import '../domain/repos/unit_render_repository.dart';

/// Hand-authored `.riv` (Rive) backend - a real-time native-engine
/// runtime (state machines/bones), tried before Lottie/procedural. Drop
/// `assets/models/<key>.riv` to use it for that key; nothing else needs to
/// change. There is no scripted generator for this format today (unlike
/// Lottie's `tool/lottie_gen/`) - `.riv` files are authored by hand in the
/// Rive editor.
class RiveUnitRenderRepositoryImpl implements UnitRenderRepository {
  @override
  Future<PositionComponent> render({
    required String key,
    required Vector2 size,
    required Future<PositionComponent> Function() fallback,
  }) async {
    final path = 'assets/models/$key.riv';
    if (await _assetExists(path)) {
      try {
        await frive.RiveNative.init();
        final file = await frive.File.asset(
          path,
          riveFactory: frive.Factory.flutter,
        );
        if (file != null) {
          final artboard = await frive.loadArtboard(file);
          return frive.RiveComponent(artboard: artboard, size: size);
        }
      } catch (_) {
        // Fall through - no valid Rive asset for this key.
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
