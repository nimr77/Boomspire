import 'package:flame/sprite.dart';

import 'enemy_component.dart';
import 'enemy_sprites.dart';

class GreenSoldierComponent extends EnemyComponent {
  GreenSoldierComponent({required super.blueprint});

  @override
  Future<Sprite> buildSprite() => EnemySpriteFactory.soldier();
}
