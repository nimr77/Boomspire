import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../domain/enums/biome.dart';

WindStyle? _windStyleFor(Biome biome) => switch (biome) {
  Biome.grassPlains || Biome.savanna => WindStyle.grass,
  Biome.mountainForest => WindStyle.autumn,
  Biome.snowTundra || Biome.frozenPeaks => WindStyle.snow,
  Biome.desertDunes => WindStyle.sand,
  Biome.cityRuins || Biome.sea => null,
};

// Leaf colors for [WindStyle.autumn] - a wider mixed autumn palette (gold,
// olive green, burnt orange, brick red, maroon, umber) picked per-particle
// so a gust reads as a real mixed-color leaf fall, not just 2-3 repeats.
const _autumnLeafColors = [
  ui.Color(0xFFE0B23A),
  ui.Color(0xFF7FA33C),
  ui.Color(0xFFC1502D),
  ui.Color(0xFFD97B29),
  ui.Color(0xFF8B3A2B),
  ui.Color(0xFFB8860B),
];

/// Biome-flavored blown particles (grass clippings, snow flurries, blown
/// sand, or tumbling autumn leaves) drifting sideways across the arena - a
/// lightweight ambient cue that a scene's terrain isn't static, on top of
/// `CloudLayerComponent`. Purely decorative, same as the cloud layer;
/// renders nothing for biomes with no matching [WindStyle]. Motion is
/// gust-modulated (a slow shared sine factor on speed) rather than
/// constant-speed streaks, so it reads as natural wind rather than a
/// conveyor belt.
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
    final count = switch (style) {
      WindStyle.snow => 50,
      WindStyle.autumn => 26,
      WindStyle.grass || WindStyle.sand => 30,
    };
    for (var i = 0; i < count; i++) {
      _particles.add(
        _WindParticle(
          position: Vector2(
            rnd.nextDouble() * _arenaSize.x,
            rnd.nextDouble() * _arenaSize.y,
          ),
          speed: switch (style) {
            WindStyle.grass => 45 + rnd.nextDouble() * 35,
            WindStyle.snow => 22 + rnd.nextDouble() * 26,
            WindStyle.sand => 90 + rnd.nextDouble() * 70,
            WindStyle.autumn => 18 + rnd.nextDouble() * 22,
          },
          drop: switch (style) {
            WindStyle.snow => 16 + rnd.nextDouble() * 18,
            WindStyle.autumn => 12 + rnd.nextDouble() * 14,
            WindStyle.grass || WindStyle.sand => 0,
          },
          scale: 0.5 + rnd.nextDouble() * 1.0,
          opacity: 0.12 + rnd.nextDouble() * 0.3,
          bobPhase: rnd.nextDouble() * 2 * pi,
          gustPhase: rnd.nextDouble() * 2 * pi,
          rotation: rnd.nextDouble() * 2 * pi,
          rotationSpeed: (rnd.nextDouble() - 0.5) * 2.4,
          colorIndex: rnd.nextInt(_autumnLeafColors.length),
        ),
      );
    }
  }

  @override
  void render(ui.Canvas canvas) {
    final style = _style;
    if (style == null) return;

    for (final p in _particles) {
      final bob = sin(p.bobPhase) * 2;
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
          canvas.drawLine(center, center.translate(-22 * p.scale, 0), paint);
        case WindStyle.autumn:
          final leafSize = 5 * p.scale;
          canvas.save();
          canvas.translate(center.dx, center.dy);
          canvas.rotate(p.rotation);
          canvas.drawOval(
            ui.Rect.fromCenter(
              center: ui.Offset.zero,
              width: leafSize * 2,
              height: leafSize,
            ),
            ui.Paint()
              ..color = _autumnLeafColors[p.colorIndex]
                  .withValues(alpha: p.opacity),
          );
          canvas.restore();
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final p in _particles) {
      p.gustPhase += dt * 0.6;
      final gust = 0.7 + 0.3 * sin(p.gustPhase);
      p.position.x += p.speed * gust * dt;
      p.position.y += p.drop * gust * dt;
      p.bobPhase += dt * 1.2;
      p.rotation += p.rotationSpeed * dt;
      if (p.position.x > _arenaSize.x + 20) {
        p.position.x = -20;
        p.position.y = _rnd.nextDouble() * _arenaSize.y;
      }
      if (p.position.y > _arenaSize.y + 20) {
        p.position.y = -20;
      }
    }
  }
}

/// Which flavor of blown-particle effect a biome gets - `null` means the
/// biome has no wind effect at all (e.g. the sea/city-ruins scenes).
/// [WindStyle.autumn] is the mixed yellow/green/red tumbling-leaf fall used
/// for forest scenes.
enum WindStyle { grass, snow, sand, autumn }

class _WindParticle {
  Vector2 position;
  final double speed;
  final double drop;
  final double scale;
  final double opacity;
  double bobPhase;
  double gustPhase;
  double rotation;
  final double rotationSpeed;
  final int colorIndex;

  _WindParticle({
    required this.position,
    required this.speed,
    required this.drop,
    required this.scale,
    required this.opacity,
    required this.bobPhase,
    required this.gustPhase,
    required this.rotation,
    required this.rotationSpeed,
    required this.colorIndex,
  });
}

