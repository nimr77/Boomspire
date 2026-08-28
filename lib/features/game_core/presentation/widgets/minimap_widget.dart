import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../boomspire_game.dart';
import 'game_core_minimap_painter.dart';

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

class _MinimapWidgetState extends State<MinimapWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<int> _tick = ValueNotifier(0);

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

    return ValueListenableBuilder<int>(
      valueListenable: _tick,
      builder: (context, _, _) {
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
              painter: GameCoreMinimapPainter(game: widget.game),
              size: size,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _tick.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Flutter widgets don't repaint on their own every frame the way a
    // Flame component does - a ticker drives the minimap's live redraw
    // (tower/unit dots, camera rect) in step with the game underneath it.
    _ticker = createTicker((_) => _tick.value++)..start();
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
