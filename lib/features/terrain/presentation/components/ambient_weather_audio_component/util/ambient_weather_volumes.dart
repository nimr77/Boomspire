import '../../../../../game_core/domain/models/game_config.dart';

AmbientWeatherVolumes ambientWeatherVolumes({
  required double windStrength,
  required double rainIntensity,
  required double combatIntensity,
}) {
  final duck = 1 - combatIntensity * GameConfig.combatAmbientDuckStrength;
  return (
    wind: windStrength * duck * GameConfig.ambientWindMaxVolume,
    rain: rainIntensity * duck * GameConfig.ambientRainMaxVolume,
  );
}

/// Combat-ducked wind/rain ambient volumes for one frame, used by
/// `AmbientWeatherAudioComponent.update`.
typedef AmbientWeatherVolumes = ({double wind, double rain});
