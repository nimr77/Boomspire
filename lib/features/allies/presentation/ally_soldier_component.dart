import 'package:flame/sprite.dart';

import 'ally_sprites.dart';
import 'ally_unit_component.dart';

class AllySoldierComponent extends AllyUnitComponent {
  AllySoldierComponent({
    required super.blueprint,
    required super.position,
    super.level,
  });

  @override
  Future<Sprite> buildSprite() => AllySpriteFactory.soldier();
}
