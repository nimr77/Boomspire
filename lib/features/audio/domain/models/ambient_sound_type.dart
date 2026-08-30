/// A continuous, volume-adjustable background loop (as opposed to
/// [SfxType]'s fire-and-forget one-shots) - driven every frame by
/// `AmbientWeatherAudioComponent` from the live weather blend
/// (`EnvironmentSettings.sampleBlend`), see `AudioRepository.setAmbientVolume`.
enum AmbientSoundType { wind, rain }
