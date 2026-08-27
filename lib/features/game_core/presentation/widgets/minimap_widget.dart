import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../boomspire_game.dart';

/// Always-on overview of the whole arena, docked inside the bottom command
/// bar (see `HudOverlay`) instead of floating over the battlefield. Shows
/// both home bases, every standing tower/unit as a small team-coloured dot,
/// and the camera's current viewport as a stroked rectangle. Tap or drag
/// anywhere on it to recenter the camera there.
class MinimapWidget extends StatefulWidget {
  static const height = 110.0;

  final BoomspireGame game;

  const MinimapWidget({super.key, required this.game});

  @override
  State<MinimapWidget> createState() => _MinimapWidgetState();
}

class _MinimapPainter extends CustomPainter {
  final BoomspireGame game;

  _MinimapPainter({required this.game});

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
  bool shouldRepaint(covariant _MinimapPainter oldDelegate) => true;

  Vector2 _worldToMinimap(Vector2 world, Size size) {
    final arenaWidth = game.terrainMap.arenaWidth;
    final arenaHeight = game.terrainMap.arenaHeight;
    return Vector2(
      world.x / arenaWidth * size.width,
      world.y / arenaHeight * size.height,
    );
  }
}

class _MinimapWidgetState extends State<MinimapWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  Widget build(BuildContext context) {
    // The HUD is a plain Flutter sibling widget, not gated by Flame's own
    // load lifecycle, so it can build before `onLoad` sets `terrainMap`.
    if (!widget.game.terrainReady) {
      return const SizedBox(
        width: MinimapWidget.height,
        height: MinimapWidget.height,
      );
    }
    final arenaWidth = widget.game.terrainMap.arenaWidth;
    final arenaHeight = widget.game.terrainMap.arenaHeight;
    final width = MinimapWidget.height * (arenaWidth / arenaHeight);
    final size = Size(width, MinimapWidget.height);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) => _navigateTo(details.localPosition, size),
      onPanUpdate: (details) => _navigateTo(details.localPosition, size),
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: const Color(0xCC0F1319),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          painter: _MinimapPainter(game: widget.game),
          size: size,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Flutter widgets don't repaint on their own every frame the way a
    // Flame component does - a ticker drives the minimap's live redraw
    // (tower/unit dots, camera rect) in step with the game underneath it.
    _ticker = createTicker((_) => setState(() {}))..start();
  }

  void _navigateTo(Offset local, Size size) {
    if (!widget.game.terrainReady) return;
    final arenaWidth = widget.game.terrainMap.arenaWidth;
    final arenaHeight = widget.game.terrainMap.arenaHeight;
    final dx = local.dx.clamp(0.0, size.width);
    final dy = local.dy.clamp(0.0, size.height);
    widget.game.world.centerCameraOn(
      Vector2(dx / size.width * arenaWidth, dy / size.height * arenaHeight),
    );
  }
}
