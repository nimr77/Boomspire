import 'package:flame/sprite.dart';

import 'enemy_component.dart';
import 'enemy_sprites.dart';

class AirDroneComponent extends EnemyComponent {
  AirDroneComponent({required super.blueprint});

  @override
  Future<Sprite> buildSprite() => EnemySpriteFactory.airDrone();
}
