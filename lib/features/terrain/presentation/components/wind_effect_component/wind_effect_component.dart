import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../../../../game_core/presentation/boomspire_game.dart';
import '../../../domain/enums/biome.dart';
import '../../../domain/enums/wind_type.dart';
import 'util/paint_ash_particle.dart';
import 'util/paint_autumn_leaf_particle.dart';
import 'util/paint_dust_particle.dart';
import 'util/paint_grass_leaf_particle.dart';
import 'util/paint_sand_particle.dart';
import 'util/paint_snow_particle.dart';
import 'util/spawn_wind_particles.dart';
import 'util/wind_gust_factor.dart';
import 'util/wind_particle_bob.dart';
import 'util/wind_particle_respawn_y.dart';

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
      final bob = windParticleBob(p.bobPhase);
      final x = p.position.x;
      final y = p.position.y + bob;
      switch (style) {
        case WindType.grassLeaves:
          paintGrassLeafParticle(
            canvas,
            x: x,
            y: y,
            scale: p.scale,
            opacity: p.opacity,
          );
        case WindType.snow:
          paintSnowParticle(
            canvas,
            x: x,
            y: y,
            scale: p.scale,
            opacity: p.opacity,
          );
        case WindType.sand:
          paintSandParticle(
            canvas,
            x: x,
            y: y,
            scale: p.scale,
            opacity: p.opacity,
          );
        case WindType.dust:
          paintDustParticle(
            canvas,
            x: x,
            y: y,
            scale: p.scale,
            opacity: p.opacity,
          );
        case WindType.autumnLeaves:
          paintAutumnLeafParticle(
            canvas,
            x: x,
            y: y,
            scale: p.scale,
            opacity: p.opacity,
            rotation: p.rotation,
            colorIndex: p.colorIndex,
          );
        case WindType.ash:
          paintAshParticle(
            canvas,
            x: x,
            y: y,
            scale: p.scale,
            opacity: p.opacity,
            colorIndex: p.colorIndex,
          );
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
      final gust = windGustFactor(p.gustPhase);
      p.position.x += p.speed * gust * dt;
      p.position.y += p.drop * gust * dt;
      p.bobPhase += dt * 1.2;
      p.rotation += p.rotationSpeed * dt;
      if (p.position.x > _arenaSize.x + 20) {
        p.position.x = -20;
        p.position.y = windParticleRespawnY(_arenaSize.y);
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
    final spawned = spawnWindParticles(
      style: style,
      arenaWidth: _arenaSize.x,
      arenaHeight: _arenaSize.y,
    );
    for (final particle in spawned) {
      _particles.add(
        _WindParticle(
          position: Vector2(particle.x, particle.y),
          speed: particle.speed,
          drop: particle.drop,
          scale: particle.scale,
          opacity: particle.opacity,
          bobPhase: particle.bobPhase,
          gustPhase: particle.gustPhase,
          rotation: particle.rotation,
          rotationSpeed: particle.rotationSpeed,
          colorIndex: particle.colorIndex,
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
