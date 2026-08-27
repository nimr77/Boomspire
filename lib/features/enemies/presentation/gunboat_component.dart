import 'package:flame/sprite.dart';

import 'enemy_component.dart';
import 'enemy_sprites.dart';

/// The "big unit" naval enemy - only spawned on sea scenes. Behaves like any
/// other ground-pathing unit (it "sails" the water tiles the same grid uses
/// for land), it just reads visually as a boat and is the intended target
/// for the Rocket Silo's damage bonus vs [EnemyBlueprint.isSeaUnit] units.
class GunboatComponent extends EnemyComponent {
  GunboatComponent({required super.blueprint});

  @override
  Future<Sprite> buildSprite() => EnemySpriteFactory.gunboat();
}
