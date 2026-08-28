import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../domain/enums/biome.dart';

/// Which flavor of blown-particle effect a biome gets - `null` means the
/// biome has no wind effect at all (e.g. the sea/city-ruins scenes).
enum WindStyle { grass, snow, sand }

WindStyle? _windStyleFor(Biome biome) => switch (biome) {
  Biome.grassPlains || Biome.savanna || Biome.mountainForest => WindStyle.grass,
  Biome.snowTundra || Biome.frozenPeaks => WindStyle.snow,
  Biome.desertDunes => WindStyle.sand,
  Biome.cityRuins || Biome.sea => null,
};

/// Biome-flavored blown particles (grass clippings, snow flurries, or
/// blown sand) drifting sideways across the arena - a lightweight ambient
/// cue that a scene's terrain isn't static, on top of `CloudLayerComponent`.
/// Purely decorative, same as the cloud layer; renders nothing for biomes
/// with no matching [WindStyle].
class WindEffectComponent extends PositionComponent {
  final Vector2 _arenaSize;
  final WindStyle? _style;
  final Random _rnd = Random();

  final List<_WindParticle> _particles = [];

  WindEffectComponent({required Vector2 arenaSize, required Biome biome})
    : _arenaSize = arenaSize,
      _style = _windStyleFor(biome),
      super(position: Vector2.zero(), size: arenaSize, priority: 150);

  @override
  Future<void> onLoad() async {
    final style = _style;
    if (style == null) return;

    final rnd = Random(13);
    final count = style == WindStyle.snow ? 70 : 45;
    for (var i = 0; i < count; i++) {
      _particles.add(
        _WindParticle(
          position: Vector2(
            rnd.nextDouble() * _arenaSize.x,
            rnd.nextDouble() * _arenaSize.y,
          ),
          speed: switch (style) {
            WindStyle.grass => 60 + rnd.nextDouble() * 60,
            WindStyle.snow => 30 + rnd.nextDouble() * 40,
            WindStyle.sand => 110 + rnd.nextDouble() * 90,
          },
          drop: style == WindStyle.snow ? 18 + rnd.nextDouble() * 22 : 0,
          scale: 0.5 + rnd.nextDouble() * 1.0,
          opacity: 0.15 + rnd.nextDouble() * 0.35,
          bobPhase: rnd.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final p in _particles) {
      p.position.x += p.speed * dt;
      p.position.y += p.drop * dt;
      p.bobPhase += dt * 2;
      if (p.position.x > _arenaSize.x + 20) {
        p.position.x = -20;
        p.position.y = _rnd.nextDouble() * _arenaSize.y;
      }
      if (p.position.y > _arenaSize.y + 20) {
        p.position.y = -20;
      }
    }
  }

  @override
  void render(ui.Canvas canvas) {
    final style = _style;
    if (style == null) return;

    for (final p in _particles) {
      final bob = sin(p.bobPhase) * 3;
      final center = ui.Offset(p.position.x, p.position.y + bob);
      switch (style) {
        case WindStyle.grass:
          final paint = ui.Paint()
            ..color = const ui.Color(0xFFB7C97A).withValues(alpha: p.opacity)
            ..strokeWidth = 2 * p.scale
            ..strokeCap = ui.StrokeCap.round;
          canvas.drawLine(
            center,
            center.translate(-14 * p.scale, 4 * p.scale),
            paint,
          );
        case WindStyle.snow:
          canvas.drawCircle(
            center,
            2.5 * p.scale,
            ui.Paint()
              ..color = const ui.Color(0xFFFFFFFF).withValues(alpha: p.opacity),
          );
        case WindStyle.sand:
          final paint = ui.Paint()
            ..color = const ui.Color(0xFFD8C08A).withValues(alpha: p.opacity)
            ..strokeWidth = 1.5 * p.scale
            ..strokeCap = ui.StrokeCap.round;
          canvas.drawLine(
            center,
            center.translate(-22 * p.scale, 0),
            paint,
          );
      }
    }
  }
}

class _WindParticle {
  Vector2 position;
  final double speed;
  final double drop;
  final double scale;
  final double opacity;
  double bobPhase;

  _WindParticle({
    required this.position,
    required this.speed,
    required this.drop,
    required this.scale,
    required this.opacity,
    required this.bobPhase,
  });
}
