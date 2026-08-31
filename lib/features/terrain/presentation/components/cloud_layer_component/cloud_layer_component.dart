import 'dart:ui' as ui;

import 'package:flame/components.dart';

import 'util/paint_cloud.dart';
import 'util/paint_fog_bank.dart';
import 'util/spawn_cloud_layer_entities.dart';

/// Soft drifting cloud puffs (high, fast-fading parallax layer) plus a low
/// ground-hugging fog band, rendered above the entire scene for a light
/// "aerial view" depth cue. Purely decorative for now - weather effects
/// with real gameplay impact (fog/rain) build on top of this later.
class CloudLayerComponent extends PositionComponent {
  final Vector2 _arenaSize;

  final List<_Cloud> _clouds = [];
  final List<_FogBank> _fogBanks = [];
  CloudLayerComponent({required Vector2 arenaSize})
    : _arenaSize = arenaSize,
      super(position: Vector2.zero(), size: arenaSize, priority: 200);

  @override
  Future<void> onLoad() async {
    final spawned = spawnCloudLayerEntities(
      arenaWidth: _arenaSize.x,
      arenaHeight: _arenaSize.y,
      cloudCount: 9,
      fogCount: 6,
    );
    for (final cloud in spawned.clouds) {
      _clouds.add(
        _Cloud(
          position: Vector2(cloud.x, cloud.y),
          speed: cloud.speed,
          scale: cloud.scale,
          baseOpacity: cloud.baseOpacity,
          seed: cloud.seed,
          bobPhase: cloud.bobPhase,
          depth: cloud.depth,
        ),
      );
    }
    for (final fog in spawned.fogBanks) {
      _fogBanks.add(
        _FogBank(
          position: Vector2(fog.x, fog.y),
          speed: fog.speed,
          scale: fog.scale,
          baseOpacity: fog.baseOpacity,
          seed: fog.seed,
          bobPhase: fog.bobPhase,
        ),
      );
    }
  }

  @override
  void render(ui.Canvas canvas) {
    // Ground fog first so clouds still read as "above" it.
    for (final fog in _fogBanks) {
      paintFogBank(
        canvas,
        seed: fog.seed,
        positionX: fog.position.x,
        positionY: fog.position.y,
        bobPhase: fog.bobPhase,
        scale: fog.scale,
        baseOpacity: fog.baseOpacity,
      );
    }

    for (final cloud in _clouds) {
      paintCloud(
        canvas,
        seed: cloud.seed,
        positionX: cloud.position.x,
        positionY: cloud.position.y,
        bobPhase: cloud.bobPhase,
        scale: cloud.scale,
        baseOpacity: cloud.baseOpacity,
        depth: cloud.depth,
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
}

class _Cloud {
  Vector2 position;

  final double speed;
  final double scale;
  final double baseOpacity;
  final int seed;
  double bobPhase;
  final double depth;
  _Cloud({
    required this.position,
    required this.speed,
    required this.scale,
    required this.baseOpacity,
    required this.seed,
    required this.bobPhase,
    required this.depth,
  });
}

class _FogBank {
  Vector2 position;

  final double speed;
  final double scale;
  final double baseOpacity;
  final int seed;
  double bobPhase;
  _FogBank({
    required this.position,
    required this.speed,
    required this.scale,
    required this.baseOpacity,
    required this.seed,
    required this.bobPhase,
  });
}
