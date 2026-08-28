import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart';

import '../boomspire_game.dart';

/// Paints the minimap's contents each tick: both home bases, every
/// standing tower/unit as a small team-coloured dot, and the camera's
/// current viewport as a stroked rectangle.
class GameCoreMinimapPainter extends CustomPainter {
  final BoomspireGame game;

  GameCoreMinimapPainter({required this.game});

  @override
  void paint(Canvas canvas, Size size) {
    void dot(Vector2 worldPosition, Color color, double radius) {
      final p = _worldToMinimap(worldPosition, size);
      canvas.drawCircle(Offset(p.x, p.y), radius, Paint()..color = color);
    }

    final playerBase = game.world.playerHomeBase;
    if (playerBase != null) {
      dot(playerBase.position, const Color(0xFF4FC3F7), 4);
    }
    final aiBase = game.world.aiHomeBase;
    if (aiBase != null) {
      dot(aiBase.position, const Color(0xFFFF6D00), 4);
    }
    for (final tower in game.world.activeTowers) {
      dot(tower.position, tower.owner.color, 1.8);
    }
    for (final unit in game.world.activeUnits) {
      if (unit.destroyed) continue;
      dot(unit.position, unit.team.color, 1.3);
    }

    final camTopLeft = _worldToMinimap(game.world.cameraPosition, size);
    final camBottomRight = _worldToMinimap(
      game.world.cameraPosition + game.camera.viewport.virtualSize,
      size,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        camTopLeft.x,
        camTopLeft.y,
        camBottomRight.x,
        camBottomRight.y,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = Colors.white,
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
