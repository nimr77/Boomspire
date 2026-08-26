import '../models/sfx_type.dart';

/// Abstraction over sound effect playback so presentation code never talks
/// to a concrete audio engine directly.
abstract class AudioRepository {
  Future<void> preload();
  void play(SfxType type, {double volume = 1});
}
