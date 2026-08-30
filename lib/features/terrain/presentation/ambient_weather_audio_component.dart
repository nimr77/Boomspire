import 'package:flame/components.dart';

import '../../audio/domain/models/ambient_sound_type.dart';
import '../../game_core/domain/models/game_config.dart';
import '../../game_core/presentation/boomspire_game.dart';

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
    final duck =
        1 - game.combatIntensity * GameConfig.combatAmbientDuckStrength;
    game.audioRepository.setAmbientVolume(
      AmbientSoundType.wind,
      weather.windStrength * duck * GameConfig.ambientWindMaxVolume,
    );
    game.audioRepository.setAmbientVolume(
      AmbientSoundType.rain,
      weather.rainIntensity * duck * GameConfig.ambientRainMaxVolume,
    );
  }
}
