import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'boomspire_game.dart';

/// Always-on-screen overview of the whole arena, docked to the bottom-left
/// of the camera viewport (screen space - added to `camera.viewport`, so it
/// never pans/zooms with the world). Shows both home bases, every standing
/// tower/unit as a small team-coloured dot, and the camera's current
/// viewport as a stroked rectangle. Tapping anywhere on it recenters the
/// camera there.
class MinimapComponent extends PositionComponent
    with HasGameReference<BoomspireGame>, TapCallbacks {
  static const _mapSize = 168.0;
  static const _margin = 16.0;

  MinimapComponent() : super(size: Vector2.all(_mapSize), priority: 1000);

  @override
  bool containsLocalPoint(Vector2 point) =>
      point.x >= 0 &&
      point.x <= _mapSize &&
      point.y >= 0 &&
      point.y <= _mapSize;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _reposition();
  }

  @override
  Future<void> onLoad() async {
    _reposition();
  }

  @override
  void onTapDown(TapDownEvent event) {
    final arenaWidth = game.terrainMap.arenaWidth;
    final arenaHeight = game.terrainMap.arenaHeight;
    final tapped = Vector2(
      event.localPosition.x / _mapSize * arenaWidth,
      event.localPosition.y / _mapSize * arenaHeight,
    );
    game.world.centerCameraOn(tapped);
  }

  @override
  void render(ui.Canvas canvas) {
    final panelRect = ui.Rect.fromLTWH(0, 0, _mapSize, _mapSize);
    final panelRRect = ui.RRect.fromRectAndRadius(
      panelRect,
      const ui.Radius.circular(10),
    );
    canvas.drawRRect(
      panelRRect,
      ui.Paint()..color = const ui.Color(0xCC0F1319),
    );

    void dot(Vector2 worldPosition, ui.Color color, double radius) {
      final p = _worldToMinimap(worldPosition);
      canvas.drawCircle(ui.Offset(p.x, p.y), radius, ui.Paint()..color = color);
    }

    final playerBase = game.world.playerHomeBase;
    if (playerBase != null) {
      dot(playerBase.position, const ui.Color(0xFF4FC3F7), 5);
    }
    final aiBase = game.world.aiHomeBase;
    if (aiBase != null) {
      dot(aiBase.position, const ui.Color(0xFFFF6D00), 5);
    }
    for (final tower in game.world.activeTowers) {
      dot(tower.position, tower.owner.color, 2.2);
    }
    for (final unit in game.world.activeUnits) {
      if (unit.destroyed) continue;
      dot(unit.position, unit.team.color, 1.6);
    }

    final camTopLeft = _worldToMinimap(game.world.cameraPosition);
    final camBottomRight = _worldToMinimap(
      game.world.cameraPosition + game.camera.viewport.virtualSize,
    );
    canvas.drawRect(
      ui.Rect.fromLTRB(
        camTopLeft.x,
        camTopLeft.y,
        camBottomRight.x,
        camBottomRight.y,
      ),
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const ui.Color(0xFFFFFFFF),
    );

    canvas.drawRRect(
      panelRRect,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const ui.Color(0x66FFFFFF),
    );
  }

  void _reposition() {
    final viewport = game.camera.viewport.virtualSize;
    position = Vector2(_margin, viewport.y - _mapSize - _margin);
  }

  Vector2 _worldToMinimap(Vector2 world) {
    final arenaWidth = game.terrainMap.arenaWidth;
    final arenaHeight = game.terrainMap.arenaHeight;
    return Vector2(
      world.x / arenaWidth * _mapSize,
      world.y / arenaHeight * _mapSize,
    );
  }
}
