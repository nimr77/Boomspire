import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/impact_spark_component.dart';
import '../../combat/presentation/laser_beam_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import 'tower_component.dart';
import 'tower_sprites.dart';

/// Continuous-fire energy weapon: hits instantly (no travel time) instead of
/// launching a projectile, trading high per-shot damage for a fast, precise
/// beam that can also track flying targets.
class LaserTowerComponent extends TowerComponent {
  LaserTowerComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  @override
  void fire(EnemyComponent target) {
    final accent = TowerSpriteFactory.accentColor(blueprint.type);
    target.takeDamage(effectiveDamage);
    game.world.spawn(
      LaserBeamComponent(
        start: position.clone(),
        end: target.position.clone(),
        color: accent,
      ),
    );
    game.world.spawn(
      ImpactSparkComponent(position: target.position.clone(), color: accent),
    );
    game.audioRepository.play(SfxType.laserShot, volume: 0.35);
  }
}
