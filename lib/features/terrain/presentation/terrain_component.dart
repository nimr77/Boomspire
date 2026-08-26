import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;

import '../../../core/rendering/procedural_image.dart';
import '../../game_core/presentation/circuit_defense_game.dart';
import '../domain/models/build_slot.dart';
import '../domain/models/terrain_map.dart';

/// Paints the mountain-pass terrain once to a cached image: rocky ground,
/// ridgelines, a glowing circuit road, and the buildable pads. A thin
/// dynamic overlay highlights empty pads (green/red) while in build mode.
class TerrainComponent extends PositionComponent
    with HasGameReference<CircuitDefenseGame> {
  TerrainComponent({required this.terrainMap})
    : super(
        position: Vector2.zero(),
        size: Vector2(terrainMap.arenaWidth, terrainMap.arenaHeight),
        priority: -10,
      );

  final TerrainMap terrainMap;
  late final ui.Image _baseImage;

  @override
  Future<void> onLoad() async {
    _baseImage = await renderToImage(
      size.x.round(),
      size.y.round(),
      _paintBase,
    );
  }

  void _paintBase(ui.Canvas canvas) {
    final rect = ui.Offset.zero & ui.Size(size.x, size.y);

    canvas.drawRect(
      rect,
      ui.Paint()
        ..shader = ui.Gradient.linear(
          const ui.Offset(0, 0),
          ui.Offset(0, size.y),
          const [
            ui.Color(0xFF33383f),
            ui.Color(0xFF454d5b),
            ui.Color(0xFF252a31),
          ],
        ),
    );

    final rnd = Random(42);
    for (var i = 0; i < 220; i++) {
      final x = rnd.nextDouble() * size.x;
      final y = rnd.nextDouble() * size.y;
      final r = 20 + rnd.nextDouble() * 70;
      final shade = 0.15 + rnd.nextDouble() * 0.25;
      final color = ui.Color.lerp(
        const ui.Color(0xFF1c1f24),
        const ui.Color(0xFF5c6672),
        shade,
      )!.withValues(alpha: 0.45);
      canvas.drawCircle(
        ui.Offset(x, y),
        r,
        ui.Paint()
          ..color = color
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 18),
      );
    }

    for (var i = 0; i < 40; i++) {
      final x = rnd.nextDouble() * size.x;
      final y = rnd.nextDouble() * size.y;
      final len = 40 + rnd.nextDouble() * 90;
      final angle = rnd.nextDouble() * pi;
      final p1 = ui.Offset(x, y);
      final p2 = ui.Offset(x + cos(angle) * len, y + sin(angle) * len);
      canvas.drawLine(
        p1,
        p2,
        ui.Paint()
          ..color = const ui.Color(0x33AEB8C2)
          ..strokeWidth = 3
          ..strokeCap = ui.StrokeCap.round,
      );
    }

    final path = ui.Path();
    final wps = terrainMap.waypoints;
    path.moveTo(wps.first.x, wps.first.y);
    for (final p in wps.skip(1)) {
      path.lineTo(p.x, p.y);
    }

    canvas.drawPath(
      path,
      ui.Paint()
        ..color = const ui.Color(0xFF14171b)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 64
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      ui.Paint()
        ..color = const ui.Color(0xFF2c313a)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 54
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      ui.Paint()
        ..color = const ui.Color(0xFF00E5FF).withValues(alpha: 0.55)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
    );

    for (final slot in terrainMap.buildSlots) {
      _paintPad(canvas, slot);
    }
  }

  void _paintPad(ui.Canvas canvas, BuildSlot slot) {
    final rect = ui.Rect.fromCenter(
      center: ui.Offset(slot.x, slot.y),
      width: slot.size,
      height: slot.size,
    );
    final rrect = ui.RRect.fromRectAndRadius(
      rect,
      const ui.Radius.circular(10),
    );
    canvas.drawRRect(rrect, ui.Paint()..color = const ui.Color(0xFF0d1116));
    final inner = rrect.deflate(4);
    canvas.drawRRect(
      inner,
      ui.Paint()
        ..shader = ui.Gradient.linear(rect.topLeft, rect.bottomRight, const [
          ui.Color(0xFF3d4956),
          ui.Color(0xFF20242a),
        ]),
    );
    canvas.drawRRect(
      inner,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const ui.Color(0xFF00E5FF).withValues(alpha: 0.45),
    );
  }

  @override
  void render(ui.Canvas canvas) {
    canvas.drawImage(_baseImage, ui.Offset.zero, ui.Paint());

    final selected = game.selectedTowerType.value;
    if (selected == null) return;
    final blueprint = game.towerRepository.blueprintFor(selected);
    final canAfford = game.gameState.gold >= blueprint.cost;
    for (final slot in terrainMap.buildSlots) {
      if (slot.occupied) continue;
      final rect = ui.Rect.fromCenter(
        center: ui.Offset(slot.x, slot.y),
        width: slot.size,
        height: slot.size,
      );
      final rrect = ui.RRect.fromRectAndRadius(
        rect,
        const ui.Radius.circular(10),
      );
      canvas.drawRRect(
        rrect,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = (canAfford ? Colors.greenAccent : Colors.redAccent)
              .withValues(alpha: 0.9),
      );
    }
  }
}
