import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

import '../domain/models/ambient_sound_type.dart';
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
    SfxType.vehicleEngine: 'vehicle_engine.wav',
    SfxType.vehicleExplosion: 'vehicle_explosion.wav',
    SfxType.soldierPop: 'soldier_pop.wav',
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
    SfxType.vehicleEngine: 4,
    SfxType.vehicleExplosion: 4,
    SfxType.soldierPop: 6,
  };

  static const _ambientFiles = <AmbientSoundType, String>{
    AmbientSoundType.wind: 'wind_ambience.wav',
    AmbientSoundType.rain: 'rain_ambience.wav',
  };

  final Map<SfxType, AudioPool> _pools = {};

  /// Looping player for each ambience once it's actually been started (see
  /// [setAmbientVolume]) - absent until first needed, so a scene with no
  /// wind/rain in its weather timeline never spins one up at all.
  final Map<AmbientSoundType, AudioPlayer> _ambientPlayers = {};

  /// Guards [setAmbientVolume] against starting the same ambience twice
  /// while its (async) first [FlameAudio.loop] call is still in flight.
  final Set<AmbientSoundType> _startingAmbient = {};

  final Map<AmbientSoundType, double> _ambientTargetVolume = {};

  @override
  void play(SfxType type, {double volume = 1}) {
    final pool = _pools[type];
    if (pool == null) return;
    unawaited(pool.start(volume: volume));
  }

  @override
  Future<void> preload() async {
    await FlameAudio.audioCache.loadAll([
      ..._files.values,
      ..._ambientFiles.values,
    ]);
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

  @override
  void setAmbientVolume(AmbientSoundType type, double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    _ambientTargetVolume[type] = clamped;
    final player = _ambientPlayers[type];
    if (player != null) {
      unawaited(player.setVolume(clamped));
      return;
    }
    // Never played yet - only worth spinning up a real looping player once
    // it's actually audible, and only one in-flight start at a time.
    if (clamped <= 0.001 || _startingAmbient.contains(type)) return;
    _startingAmbient.add(type);
    unawaited(_startAmbient(type));
  }

  double _pendingAmbientVolume(AmbientSoundType type) =>
      _ambientTargetVolume[type] ?? 0;

  Future<void> _startAmbient(AmbientSoundType type) async {
    final file = _ambientFiles[type];
    if (file == null) return;
    final player = await FlameAudio.loop(file, volume: 0);
    _ambientPlayers[type] = player;
    _startingAmbient.remove(type);
    // The target may have changed (even dropped back to 0) while awaiting.
    await player.setVolume(_pendingAmbientVolume(type));
  }
}
