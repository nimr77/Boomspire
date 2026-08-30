import '../models/ambient_sound_type.dart';
import '../models/sfx_type.dart';

/// Abstraction over sound effect playback so presentation code never talks
/// to a concrete audio engine directly.
abstract class AudioRepository {
  void play(SfxType type, {double volume = 1});
  Future<void> preload();

  /// Fades a continuous ambience [type] loop to [volume] (0..1, 0 stops
  /// it) - unlike [play], this is meant to be called every frame with a
  /// smoothly-changing value rather than once per event.
  void setAmbientVolume(AmbientSoundType type, double volume);
}
