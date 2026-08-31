import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, FontWeight, TextStyle;

import '../../towers/presentation/tower_sprites.dart';
import 'boomspire_game.dart';
import 'util/paint_ghost_placement.dart';

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

    paintGhostPlacement(
      canvas,
      center: offset,
      half: grid.cellSize * 0.45,
      accent: accent,
      pulse: pulse,
      range: blueprint.range,
      minRange: blueprint.minRange,
    );
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
