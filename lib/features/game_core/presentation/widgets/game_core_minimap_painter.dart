import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart';

import '../boomspire_game.dart';
import '../util/paint_minimap.dart';

/// Paints the minimap's contents each tick: both home bases, every
/// standing tower/unit as a small team-coloured dot, and the camera's
/// current viewport as a stroked rectangle.
class GameCoreMinimapPainter extends CustomPainter {
  final BoomspireGame game;

  GameCoreMinimapPainter({required this.game});

  @override
  void paint(Canvas canvas, Size size) {
    Offset toMinimap(Vector2 world) {
      final p = _worldToMinimap(world, size);
      return Offset(p.x, p.y);
    }

    final dots = <({Offset point, Color color, double radius})>[];

    final playerBase = game.world.playerHomeBase;
    if (playerBase != null) {
      dots.add((
        point: toMinimap(playerBase.position),
        color: const Color(0xFF4FC3F7),
        radius: 4.0,
      ));
    }
    final aiBase = game.world.aiHomeBase;
    if (aiBase != null) {
      dots.add((
        point: toMinimap(aiBase.position),
        color: const Color(0xFFFF6D00),
        radius: 4.0,
      ));
    }
    for (final tower in game.world.activeTowers) {
      dots.add((
        point: toMinimap(tower.position),
        color: tower.owner.color,
        radius: 1.8,
      ));
    }
    for (final unit in game.world.activeUnits) {
      if (unit.destroyed) continue;
      dots.add((
        point: toMinimap(unit.position),
        color: unit.team.color,
        radius: 1.3,
      ));
    }

    final camTopLeft = _worldToMinimap(game.world.cameraPosition, size);
    final camBottomRight = _worldToMinimap(
      game.world.cameraPosition + game.camera.viewport.virtualSize,
      size,
    );

    paintMinimap(
      canvas,
      dots: dots,
      cameraRect: Rect.fromLTRB(
        camTopLeft.x,
        camTopLeft.y,
        camBottomRight.x,
        camBottomRight.y,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant GameCoreMinimapPainter oldDelegate) => true;

  Vector2 _worldToMinimap(Vector2 world, Size size) {
    final arenaWidth = game.terrainMap.arenaWidth;
    final arenaHeight = game.terrainMap.arenaHeight;
    return Vector2(
      world.x / arenaWidth * size.width,
      world.y / arenaHeight * size.height,
    );
  }
}
