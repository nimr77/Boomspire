import 'package:flame/sprite.dart';

import 'enemy_component.dart';
import 'enemy_sprites.dart';

class HeavySoldierComponent extends EnemyComponent {
  HeavySoldierComponent({required super.blueprint});

  @override
  Future<Sprite> buildSprite() => EnemySpriteFactory.heavySoldier();
}
