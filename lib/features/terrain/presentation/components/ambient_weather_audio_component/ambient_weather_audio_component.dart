import 'package:flame/components.dart';

import '../../../../audio/domain/models/ambient_sound_type.dart';
import '../../../../game_core/presentation/boomspire_game.dart';
import 'util/ambient_weather_volumes.dart';

/// Keeps the wind/rain ambience loops tracking the live weather blend from
/// `BoomspireGame.weatherFocus` every frame - the aural counterpart to
/// `WindEffectComponent`/`CloudLayerComponent`'s always-on visual layers.
/// Volume also ducks under heavy weapon fire
/// (`BoomspireGame.combatIntensity`) so ambience never fights combat SFX
/// for attention, see `GameConfig.combatAmbientDuckStrength`.
class AmbientWeatherAudioComponent extends Component
    with HasGameReference<BoomspireGame> {
  @override
  void update(double dt) {
    super.update(dt);
    final weather = game.scene.environment.sampleBlend(
      game.weatherFocus.weights,
    );
    final volumes = ambientWeatherVolumes(
      windStrength: weather.windStrength,
      rainIntensity: weather.rainIntensity,
      combatIntensity: game.combatIntensity,
    );
    game.audioRepository.setAmbientVolume(
      AmbientSoundType.wind,
      volumes.wind,
    );
    game.audioRepository.setAmbientVolume(
      AmbientSoundType.rain,
      volumes.rain,
    );
  }
}
