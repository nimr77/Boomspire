import 'package:flame/sprite.dart';

import 'enemy_component.dart';
import 'enemy_sprites.dart';

/// Enemy Rocket Barrage vehicle - a rocket-pod carrier that can engage both
/// ground and air targets with a splash-damage salvo.
class RocketBarrageComponent extends EnemyComponent {
  RocketBarrageComponent({required super.blueprint});

  @override
  Future<Sprite> buildSprite() => EnemySpriteFactory.rocketBarrage();
}
