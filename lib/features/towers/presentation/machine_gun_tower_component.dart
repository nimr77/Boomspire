import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/bullet_component.dart';
import '../../combat/presentation/muzzle_flash_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import 'tower_component.dart';

class MachineGunTowerComponent extends TowerComponent {
  MachineGunTowerComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  @override
  void fire(EnemyComponent target) {
    final dir = (target.position - position).normalized();
    final spawnPos = position + dir * (size.x / 2);
    game.world.spawn(
      BulletComponent(start: spawnPos, target: target, damage: effectiveDamage),
    );
    game.world.spawn(MuzzleFlashComponent(position: spawnPos));
    game.audioRepository.play(SfxType.machineGunShot, volume: 0.5);
  }
}
