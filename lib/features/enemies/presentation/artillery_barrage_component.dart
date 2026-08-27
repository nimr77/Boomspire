import 'package:flame/sprite.dart';

import 'enemy_component.dart';
import 'enemy_sprites.dart';

/// Enemy artillery vehicle - a slow, hard-hitting mortar carrier that always
/// prefers to detour and shell towers/structures over engaging ally units
/// (see [MobileUnitBlueprint.prefersStructures]), falling back to rushing
/// the base once nothing is left standing in range.
class ArtilleryBarrageComponent extends EnemyComponent {
  ArtilleryBarrageComponent({required super.blueprint});

  @override
  Future<Sprite> buildSprite() => EnemySpriteFactory.artilleryBarrage();
}
