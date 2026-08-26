import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../../enemies/domain/models/enemy_type.dart';
import '../../enemies/presentation/enemy_sprites.dart';
import 'circuit_defense_game.dart';

/// Marks where enemies enter the arena: instead of a plain "start" circle,
/// shows a small row of colored icons for every enemy type featured in the
/// current wave, with a chevron pointing at the actual spawn point.
class SpawnIndicatorComponent extends PositionComponent
    with HasGameReference<CircuitDefenseGame> {
  int _cachedWave = -1;
  List<EnemyType> _types = [];

  SpawnIndicatorComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2(140, 44),
        anchor: Anchor.bottomCenter,
        priority: 6,
      );

  @override
  void render(ui.Canvas canvas) {
    if (_types.isEmpty) return;

    const spacing = 28.0;
    final startX = size.x / 2 - (_types.length - 1) * spacing / 2;
    for (var i = 0; i < _types.length; i++) {
      final color = EnemySpriteFactory.accentColor(_types[i]);
      final cx = startX + i * spacing;
      canvas.drawCircle(
        ui.Offset(cx, 10),
        9,
        ui.Paint()..color = color.withValues(alpha: 0.85),
      );
      canvas.drawCircle(
        ui.Offset(cx, 10),
        9,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const ui.Color(0xFFFFFFFF).withValues(alpha: 0.6),
      );
    }

    final chevron = ui.Path()
      ..moveTo(size.x / 2 - 10, 26)
      ..lineTo(size.x / 2, 36)
      ..lineTo(size.x / 2 + 10, 26);
    canvas.drawPath(
      chevron,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = ui.StrokeCap.round
        ..color = const ui.Color(0xFFE53935).withValues(alpha: 0.75),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final wave = game.gameState.currentWave;
    if (wave == _cachedWave) return;
    _cachedWave = wave;
    final def = game.waveRepository.waveDefinition(wave);
    _types = def.spawns.map((s) => s.type).toSet().toList();
  }
}
