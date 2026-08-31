import 'dart:ui' as ui;

import '../../../core/combat/team.dart';
import '../../../core/rendering/procedural_image.dart';
import 'util/paint_home_base_sprite.dart';

/// Shared "home base" art (house silhouette, roof, energy-core door,
/// antenna) - used by both [HomeBaseComponent] (the player's base) and
/// [AiHomeBaseComponent] (the AI's), tinted by the owning [Team.color] so
/// every base reads as the same kind of structure, just in its side's
/// livery. Cached per team id since a raster only needs generating once.
class HomeBaseSprite {
  static final Map<int, ui.Image> _cache = {};

  static Future<ui.Image> forTeam(Team team) async {
    final cached = _cache[team.id];
    if (cached != null) return cached;
    final image = await renderToImage(
      96,
      96,
      (canvas) => paintHomeBaseSprite(canvas, team.color),
    );
    _cache[team.id] = image;
    return image;
  }
}
