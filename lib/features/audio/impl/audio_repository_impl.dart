import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

import '../domain/models/sfx_type.dart';
import '../domain/repos/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  static const _files = <SfxType, String>{
    SfxType.machineGunShot: 'machine_gun_shot.wav',
    SfxType.rocketLaunch: 'rocket_launch.wav',
    SfxType.explosion: 'explosion.wav',
    SfxType.enemyHit: 'enemy_hit.wav',
    SfxType.enemyDeath: 'enemy_death.wav',
    SfxType.enemyEscape: 'enemy_escape.wav',
    SfxType.goldGain: 'gold_gain.wav',
    SfxType.buildPlace: 'build_place.wav',
    SfxType.waveStart: 'wave_start.wav',
    SfxType.victory: 'victory.wav',
    SfxType.defeat: 'defeat.wav',
  };

  @override
  Future<void> preload() async {
    await FlameAudio.audioCache.loadAll(_files.values.toList());
  }

  @override
  void play(SfxType type, {double volume = 1}) {
    final file = _files[type];
    if (file == null) return;
    unawaited(FlameAudio.play(file, volume: volume));
  }
}
