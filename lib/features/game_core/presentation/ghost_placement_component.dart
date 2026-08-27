import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, FontWeight, TextStyle;

import '../../towers/presentation/tower_sprites.dart';
import 'boomspire_game.dart';

/// Shows a translucent footprint + a pulsing range ring (in the selected
/// tower's accent color) at the pending build cell (see
/// [BoomspireGame.pendingPlacement]) - lets the player see a tower's
/// coverage before actually spending gold to build it. A first arena tap
/// sets the pending cell; a second tap on that same cell commits the build.
class GhostPlacementComponent extends PositionComponent
    with HasGameReference<BoomspireGame> {
  double _pulsePhase = 0;
  late final TextComponent _hint;

  GhostPlacementComponent() : super(priority: 4);

  @override
  Future<void> onLoad() async {
    _hint = TextComponent(
      anchor: Anchor.bottomCenter,
      priority: 41,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
        ),
      ),
    )..text = 'Tap again to build';
    await add(_hint);
  }

  @override
  void render(Canvas canvas) {
    final type = game.selectedTowerType.value;
    final cell = game.pendingPlacement.value;
    if (type == null || cell == null) return;

    final grid = game.terrainMap.grid;
    final center = grid.cellCenter(cell);
    final offset = Offset(center.x, center.y);
    final blueprint = game.blueprintFor(type);
    final accent = TowerSpriteFactory.accentColor(type);
    final pulse = 0.5 + 0.5 * sin(_pulsePhase);

    _hint.position = Vector2(center.x, center.y - grid.cellSize * 0.75);

    // Footprint.
    final half = grid.cellSize * 0.45;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: offset, width: half * 2, height: half * 2),
        const Radius.circular(6),
      ),
      Paint()..color = accent.withValues(alpha: 0.25),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: offset, width: half * 2, height: half * 2),
        const Radius.circular(6),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withValues(alpha: 0.7),
    );

    if (blueprint.range <= 0) return;

    // Pulsing range ring.
    canvas.drawCircle(
      offset,
      blueprint.range,
      Paint()..color = accent.withValues(alpha: 0.05 + pulse * 0.05),
    );
    canvas.drawCircle(
      offset,
      blueprint.range,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + pulse
        ..color = accent.withValues(alpha: 0.4 + pulse * 0.3),
    );

    // Dead-zone preview - mirrors the in-game ring drawn once built (see
    // `TowerComponent.render`) so the min-range limitation is visible
    // before the player commits to a build.
    if (blueprint.minRange > 0) {
      canvas.drawCircle(
        offset,
        blueprint.minRange,
        Paint()..color = const Color(0xFFE53935).withValues(alpha: 0.18),
      );
      canvas.drawCircle(
        offset,
        blueprint.minRange,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFFE53935).withValues(alpha: 0.6),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulsePhase += dt * 3;
    final cell = game.pendingPlacement.value;
    final visible = cell != null && game.selectedTowerType.value != null;
    _hint.text = visible ? 'Tap again to build' : '';
  }
}
