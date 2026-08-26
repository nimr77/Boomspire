import 'package:flame/sprite.dart';

import 'enemy_component.dart';
import 'enemy_sprites.dart';

class AttackPlaneComponent extends EnemyComponent {
  AttackPlaneComponent({required super.blueprint});

  @override
  Future<Sprite> buildSprite() => EnemySpriteFactory.attackPlane();
}
