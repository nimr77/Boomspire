import 'package:flame/sprite.dart';

import 'ally_sprites.dart';
import 'ally_unit_component.dart';

class AllyAircraftComponent extends AllyUnitComponent {
  AllyAircraftComponent({required super.blueprint, required super.position});

  @override
  Future<Sprite> buildSprite() => AllySpriteFactory.aircraft();
}
