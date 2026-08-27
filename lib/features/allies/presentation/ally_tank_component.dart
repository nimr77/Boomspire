import 'package:flame/sprite.dart';

import 'ally_sprites.dart';
import 'ally_unit_component.dart';

class AllyTankComponent extends AllyUnitComponent {
  AllyTankComponent({required super.blueprint, required super.position});

  @override
  Future<Sprite> buildSprite() => AllySpriteFactory.tank();
}
