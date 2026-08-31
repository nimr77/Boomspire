import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../../game_core/presentation/boomspire_game.dart';
import '../domain/enums/biome.dart';
import '../domain/enums/wind_type.dart';

// Leaf colors for [WindType.autumnLeaves] - a wider mixed autumn palette
// (gold, olive green, burnt orange, brick red, maroon, umber) picked
// per-particle so a gust reads as a real mixed-color leaf fall, not just
// 2-3 repeats.
const _autumnLeafColors = [
  ui.Color(0xFFE0B23A),
  ui.Color(0xFF7FA33C),
  ui.Color(0xFFC1502D),
  ui.Color(0xFFD97B29),
  ui.Color(0xFF8B3A2B),
  ui.Color(0xFFB8860B),
];

/// Biome-flavored blown particles (grass clippings, snow flurries, blown
/// sand/dust, tumbling autumn leaves, or drifting ash) blowing sideways
/// across the arena - a lightweight ambient cue that a scene's terrain
/// isn't static, on top of `CloudLayerComponent`. Purely decorative, same
/// as the cloud layer.
///
/// The style shown is [Biome.defaultWindType] unless the scene's live
/// weather keyframe explicitly overrides it (see
/// `WeatherKeyframe.resolvedWindType`) - checked every frame in [update]
/// so a dynamic weather timeline can change the look mid-match, not just
/// once at scene start. Motion is gust-modulated (a slow shared sine
/// factor on speed) rather than constant-speed streaks, so it reads as
/// natural wind rather than a conveyor belt.
class WindEffectComponent extends PositionComponent
    with HasGameReference<BoomspireGame> {
  final Vector2 _arenaSize;
  final Biome _biome;
  final Random _rnd = Random();

  WindType? _currentType;
  final List<_WindParticle> _particles = [];

  WindEffectComponent({required Vector2 arenaSize, required Biome biome})
    : _arenaSize = arenaSize,
      // External param name (`biome`) intentionally differs from the
      // private field it fills, so an initializing formal can't be used.
      // ignore: prefer_initializing_formals
      _biome = biome,
      super(position: Vector2.zero(), size: arenaSize, priority: 150);

  WindType get _resolvedType => game.scene.environment
      .sampleBlend(game.weatherFocus.weights)
      .resolvedWindType(_biome);

  @override
  Future<void> onLoad() async {
    _restyle(_resolvedType);
  }

  @override
  void render(ui.Canvas canvas) {
    final style = _currentType;
    if (style == null) return;

    for (final p in _particles) {
      final bob = sin(p.bobPhase) * 2;
      final center = ui.Offset(p.position.x, p.position.y + bob);
      switch (style) {
        case WindType.grassLeaves:
          final paint = ui.Paint()
            ..color = const ui.Color(0xFFB7C97A).withValues(alpha: p.opacity)
            ..strokeWidth = 2 * p.scale
            ..strokeCap = ui.StrokeCap.round;
          canvas.drawLine(
            center,
            center.translate(-14 * p.scale, 4 * p.scale),
            paint,
          );
        case WindType.snow:
          canvas.drawCircle(
            center,
            2.5 * p.scale,
            ui.Paint()
              ..color = const ui.Color(0xFFFFFFFF).withValues(alpha: p.opacity),
          );
        case WindType.sand:
          final paint = ui.Paint()
            ..color = const ui.Color(0xFFD8C08A).withValues(alpha: p.opacity)
            ..strokeWidth = 1.5 * p.scale
            ..strokeCap = ui.StrokeCap.round;
          canvas.drawLine(center, center.translate(-22 * p.scale, 0), paint);
        case WindType.dust:
          final paint = ui.Paint()
            ..color = const ui.Color(0xFFDCD3B8)
                .withValues(alpha: p.opacity * 0.7)
            ..strokeWidth = 1.2 * p.scale
            ..strokeCap = ui.StrokeCap.round;
          canvas.drawLine(center, center.translate(-16 * p.scale, 0), paint);
        case WindType.autumnLeaves:
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
              ..color = _autumnLeafColors[p.colorIndex].withValues(
                alpha: p.opacity,
              ),
          );
          canvas.restore();
        case WindType.ash:
          // Alternates fleck vs. smudge per-particle (fixed at spawn, not
          // re-randomized every frame) so each piece of ash keeps its own
          // identity as it drifts naturally with the gust.
          if (p.colorIndex.isEven) {
            canvas.drawCircle(
              center,
              1.6 * p.scale,
              ui.Paint()
                ..color = ui.Color.lerp(
                  const ui.Color(0xFF9e9e9e),
                  const ui.Color(0xFF2b2b2b),
                  p.opacity,
                )!.withValues(alpha: p.opacity),
            );
          } else {
            canvas.drawLine(
              center,
              center.translate(-10 * p.scale, 3 * p.scale),
              ui.Paint()
                ..color = const ui.Color(0xFF4a3524)
                    .withValues(alpha: p.opacity)
                ..strokeWidth = 1.4 * p.scale
                ..strokeCap = ui.StrokeCap.round,
            );
          }
        case WindType.automatic:
          break; // unreachable - always resolved concretely
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final resolved = _resolvedType;
    if (resolved != _currentType) _restyle(resolved);

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

  /// Rebuilds [_particles] for a newly resolved [style] - called once from
  /// [onLoad] and again whenever [update] notices the resolved style has
  /// changed (e.g. a dynamic weather keyframe switching in an ash wind).
  void _restyle(WindType style) {
    _currentType = style;
    _particles.clear();
    final rnd = Random(13);
    final count = switch (style) {
      WindType.snow => 50,
      WindType.autumnLeaves || WindType.ash => 26,
      WindType.grassLeaves || WindType.sand || WindType.dust => 30,
      WindType.automatic => 0, // unreachable - always resolved concretely
    };
    for (var i = 0; i < count; i++) {
      _particles.add(
        _WindParticle(
          position: Vector2(
            rnd.nextDouble() * _arenaSize.x,
            rnd.nextDouble() * _arenaSize.y,
          ),
          speed: switch (style) {
            WindType.grassLeaves => 45 + rnd.nextDouble() * 35,
            WindType.snow => 22 + rnd.nextDouble() * 26,
            WindType.sand => 90 + rnd.nextDouble() * 70,
            WindType.dust => 55 + rnd.nextDouble() * 40,
            WindType.autumnLeaves => 18 + rnd.nextDouble() * 22,
            WindType.ash => 16 + rnd.nextDouble() * 20,
            WindType.automatic => 0,
          },
          drop: switch (style) {
            WindType.snow => 16 + rnd.nextDouble() * 18,
            WindType.autumnLeaves => 12 + rnd.nextDouble() * 14,
            WindType.ash => 10 + rnd.nextDouble() * 12,
            WindType.grassLeaves || WindType.sand || WindType.dust => 0,
            WindType.automatic => 0,
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
}

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
