import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';

/// Soft drifting cloud puffs (high, fast-fading parallax layer) plus a low
/// ground-hugging fog band, rendered above the entire scene for a light
/// "aerial view" depth cue. Purely decorative for now - weather effects
/// with real gameplay impact (fog/rain) build on top of this later.
class CloudLayerComponent extends PositionComponent {
  CloudLayerComponent({required Vector2 arenaSize})
    : _arenaSize = arenaSize,
      super(position: Vector2.zero(), size: arenaSize, priority: 200);

  final Vector2 _arenaSize;
  final List<_Cloud> _clouds = [];
  final List<_FogBank> _fogBanks = [];

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
          baseOpacity: 0.16 + rnd.nextDouble() * 0.2,
          seed: rnd.nextInt(1 << 30),
          bobPhase: rnd.nextDouble() * 2 * pi,
          // Farther/smaller clouds drift slower and breathe more gently -
          // a cheap parallax depth cue without a real z-axis.
          depth: 0.4 + rnd.nextDouble() * 0.6,
        ),
      );
    }
    for (var i = 0; i < 6; i++) {
      _fogBanks.add(
        _FogBank(
          position: Vector2(
            rnd.nextDouble() * _arenaSize.x,
            _arenaSize.y * (0.55 + rnd.nextDouble() * 0.45),
          ),
          speed: 3 + rnd.nextDouble() * 7,
          scale: 1.1 + rnd.nextDouble() * 1.6,
          baseOpacity: 0.05 + rnd.nextDouble() * 0.07,
          seed: rnd.nextInt(1 << 30),
          bobPhase: rnd.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final cloud in _clouds) {
      cloud.position.x += cloud.speed * cloud.depth * dt;
      cloud.bobPhase += dt * 0.35 * cloud.depth;
      if (cloud.position.x - cloud.scale * 90 > _arenaSize.x) {
        cloud.position.x = -cloud.scale * 90;
      }
    }
    for (final fog in _fogBanks) {
      fog.position.x += fog.speed * dt;
      fog.bobPhase += dt * 0.25;
      if (fog.position.x - fog.scale * 140 > _arenaSize.x) {
        fog.position.x = -fog.scale * 140;
      }
    }
  }

  @override
  void render(ui.Canvas canvas) {
    // Ground fog first so clouds still read as "above" it.
    for (final fog in _fogBanks) {
      final rnd = Random(fog.seed);
      final drift = sin(fog.bobPhase) * 14;
      final base = ui.Offset(fog.position.x, fog.position.y + drift);
      final breathe = 0.75 + 0.25 * sin(fog.bobPhase * 1.3);
      final paint = ui.Paint()
        ..color = const ui.Color(0xFFDCE6EE)
            .withValues(alpha: fog.baseOpacity * breathe)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 30);
      for (var puff = 0; puff < 4; puff++) {
        final dx = (rnd.nextDouble() - 0.5) * 220 * fog.scale;
        final dy = (rnd.nextDouble() - 0.5) * 18 * fog.scale;
        final r = (60 + rnd.nextDouble() * 50) * fog.scale;
        canvas.drawOval(
          ui.Rect.fromCenter(
            center: base.translate(dx, dy),
            width: r * 2.4,
            height: r * 0.7,
          ),
          paint,
        );
      }
    }

    for (final cloud in _clouds) {
      final rnd = Random(cloud.seed);
      final drift = sin(cloud.bobPhase) * 5;
      final base = ui.Offset(cloud.position.x, cloud.position.y + drift);
      final breathe = 0.8 + 0.2 * sin(cloud.bobPhase * 1.7);
      final paint = ui.Paint()
        ..color = const ui.Color(0xFFFFFFFF)
            .withValues(alpha: cloud.baseOpacity * breathe)
        ..maskFilter = ui.MaskFilter.blur(
          ui.BlurStyle.normal,
          14 + (1 - cloud.depth) * 10,
        );
      for (var puff = 0; puff < 5; puff++) {
        final dx = (rnd.nextDouble() - 0.5) * 90 * cloud.scale;
        final dy = (rnd.nextDouble() - 0.5) * 24 * cloud.scale;
        final r = (26 + rnd.nextDouble() * 22) * cloud.scale * cloud.depth;
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
    required this.baseOpacity,
    required this.seed,
    required this.bobPhase,
    required this.depth,
  });

  Vector2 position;
  final double speed;
  final double scale;
  final double baseOpacity;
  final int seed;
  double bobPhase;
  final double depth;
}

class _FogBank {
  _FogBank({
    required this.position,
    required this.speed,
    required this.scale,
    required this.baseOpacity,
    required this.seed,
    required this.bobPhase,
  });

  Vector2 position;
  final double speed;
  final double scale;
  final double baseOpacity;
  final int seed;
  double bobPhase;
}
