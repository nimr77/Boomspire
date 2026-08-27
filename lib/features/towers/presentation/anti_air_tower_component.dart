import '../../../core/combat/attackable.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/bullet_component.dart';
import '../../combat/presentation/muzzle_flash_component.dart';
import 'tower_component.dart';

/// Rapid-fire flak battery: the only tower that can hit flying enemies.
class AntiAirTowerComponent extends TowerComponent {
  AntiAirTowerComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  @override
  void fire(Attackable target) {
    final dir = (target.position - position).normalized();
    final spawnPos = position + dir * (size.x / 2);
    game.world.spawn(
      BulletComponent(start: spawnPos, target: target, damage: effectiveDamage),
    );
    game.world.spawn(MuzzleFlashComponent(position: spawnPos));
    game.audioRepository.play(SfxType.antiAirShot, volume: 0.6);
  }
}
