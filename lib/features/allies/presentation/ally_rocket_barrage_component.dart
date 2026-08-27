import 'package:flame/sprite.dart';

import 'ally_sprites.dart';
import 'ally_unit_component.dart';

/// Player-buildable Rocket Barrage vehicle - a rocket-pod carrier that
/// engages both ground and air targets with a salvo-splash rocket. Roughly
/// the ally-side mirror of the enemy's Rocket Barrage unit.
class AllyRocketBarrageComponent extends AllyUnitComponent {
  AllyRocketBarrageComponent({
    required super.blueprint,
    required super.position,
    required super.team,
    super.level,
  });

  @override
  Future<Sprite> buildSprite() => AllySpriteFactory.rocketBarrage();
}
