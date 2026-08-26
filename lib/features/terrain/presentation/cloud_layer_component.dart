import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';

/// Soft drifting cloud puffs rendered above the entire scene for a light
/// parallax "aerial view" depth cue. Purely decorative for now - weather
/// effects with real gameplay impact (fog/rain) build on top of this later.
class CloudLayerComponent extends PositionComponent {
  CloudLayerComponent({required Vector2 arenaSize})
    : _arenaSize = arenaSize,
      super(position: Vector2.zero(), size: arenaSize, priority: 200);

  final Vector2 _arenaSize;
  final List<_Cloud> _clouds = [];

  @override
  Future<void> onLoad() async {
    final rnd = Random(7);
    for (var i = 0; i < 9; i++) {
      _clouds.add(
        _Cloud(
          position: Vector2(
            rnd.nextDouble() * _arenaSize.x,
            rnd.nextDouble() * _arenaSize.y * 0.6,
          ),
          speed: 6 + rnd.nextDouble() * 14,
          scale: 0.6 + rnd.nextDouble() * 1.1,
          opacity: 0.18 + rnd.nextDouble() * 0.22,
          seed: rnd.nextInt(1 << 30),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final cloud in _clouds) {
      cloud.position.x += cloud.speed * dt;
      if (cloud.position.x - cloud.scale * 90 > _arenaSize.x) {
        cloud.position.x = -cloud.scale * 90;
      }
    }
  }

  @override
  void render(ui.Canvas canvas) {
    for (final cloud in _clouds) {
      final rnd = Random(cloud.seed);
      final base = ui.Offset(cloud.position.x, cloud.position.y);
      final paint = ui.Paint()
        ..color = const ui.Color(0xFFFFFFFF).withValues(alpha: cloud.opacity)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 18);
      for (var puff = 0; puff < 5; puff++) {
        final dx = (rnd.nextDouble() - 0.5) * 90 * cloud.scale;
        final dy = (rnd.nextDouble() - 0.5) * 24 * cloud.scale;
        final r = (26 + rnd.nextDouble() * 22) * cloud.scale;
        canvas.drawCircle(base.translate(dx, dy), r, paint);
      }
    }
  }
}

class _Cloud {
  _Cloud({
    required this.position,
    required this.speed,
    required this.scale,
    required this.opacity,
    required this.seed,
  });

  Vector2 position;
  final double speed;
  final double scale;
  final double opacity;
  final int seed;
}
