import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

import '../domain/models/sfx_type.dart';
import '../domain/repos/audio_repository.dart';

/// Wraps `flame_audio`. Every sound is served from a pre-warmed [AudioPool]
/// instead of the plain `FlameAudio.play()` fire-and-forget call.
///
/// `FlameAudio.play()` spins up a brand-new platform audio player on every
/// single call - during a dense wave with several towers/enemies firing the
/// same frame, that can exceed the OS's limit on concurrent audio sessions
/// and start silently dropping playback (the game "goes quiet" under load).
/// Pools reuse a small, fixed set of pre-loaded players per sound instead,
/// which is both faster and can't be exhausted the way a play-per-call
/// approach can.
class AudioRepositoryImpl implements AudioRepository {
  static const _files = <SfxType, String>{
    SfxType.machineGunShot: 'machine_gun_shot.wav',
    SfxType.rocketLaunch: 'rocket_launch.wav',
    SfxType.cannonShot: 'cannon_shot.wav',
    SfxType.antiAirShot: 'anti_air_shot.wav',
    SfxType.laserShot: 'laser_shot.wav',
    SfxType.explosion: 'explosion.wav',
    SfxType.enemyHit: 'enemy_hit.wav',
    SfxType.enemyShot: 'enemy_shot.wav',
    SfxType.enemyDeath: 'enemy_death.wav',
    SfxType.enemyEscape: 'enemy_escape.wav',
    SfxType.goldGain: 'gold_gain.wav',
    SfxType.buildPlace: 'build_place.wav',
    SfxType.towerDestroyed: 'tower_destroyed.wav',
    SfxType.towerRepair: 'tower_repair.wav',
    SfxType.towerUpgrade: 'tower_upgrade.wav',
    SfxType.towerSell: 'tower_sell.wav',
    SfxType.waveStart: 'wave_start.wav',
    SfxType.victory: 'victory.wav',
    SfxType.defeat: 'defeat.wav',
  };

  /// How many overlapping instances of each sound might be needed at once -
  /// high-frequency combat SFX get a bigger pool since several towers/
  /// enemies can fire on the very same frame during a dense wave.
  static const _poolSizes = <SfxType, int>{
    SfxType.machineGunShot: 10,
    SfxType.enemyShot: 8,
    SfxType.enemyHit: 8,
    SfxType.antiAirShot: 6,
    SfxType.laserShot: 8,
    SfxType.cannonShot: 6,
    SfxType.rocketLaunch: 6,
    SfxType.explosion: 6,
    SfxType.enemyDeath: 6,
  };

  final Map<SfxType, AudioPool> _pools = {};

  @override
  void play(SfxType type, {double volume = 1}) {
    final pool = _pools[type];
    if (pool == null) return;
    unawaited(pool.start(volume: volume));
  }

  @override
  Future<void> preload() async {
    await FlameAudio.audioCache.loadAll(_files.values.toList());
    await Future.wait(
      _files.entries.map((entry) async {
        _pools[entry.key] = await FlameAudio.createPool(
          entry.value,
          minPlayers: 2,
          maxPlayers: _poolSizes[entry.key] ?? 3,
        );
      }),
    );
  }
}
