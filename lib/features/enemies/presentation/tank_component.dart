import 'package:flame/sprite.dart';

import 'enemy_component.dart';
import 'enemy_sprites.dart';

class TankComponent extends EnemyComponent {
  TankComponent({required super.blueprint});

  @override
  Future<Sprite> buildSprite() => EnemySpriteFactory.tank();
}
