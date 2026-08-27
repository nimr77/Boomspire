import 'package:flame/sprite.dart';

import 'ally_sprites.dart';
import 'ally_unit_component.dart';

class AllyLightVehicleComponent extends AllyUnitComponent {
  AllyLightVehicleComponent({
    required super.blueprint,
    required super.position,
    required super.team,
    super.level,
  });

  @override
  Future<Sprite> buildSprite() => AllySpriteFactory.lightVehicle();
}
