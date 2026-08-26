import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../audio/domain/models/sfx_type.dart';
import '../../game_core/domain/models/game_status.dart';
import '../../game_core/presentation/circuit_defense_game.dart';
import '../domain/models/enemy_blueprint.dart';
import 'floating_text_component.dart';

/// Base enemy: walks the waypoint path, tracks health, and resolves
/// death/escape (gold reward or player damage) once it leaves the field.
abstract class EnemyComponent extends PositionComponent
    with HasGameReference<CircuitDefenseGame> {
  EnemyComponent({required this.blueprint})
    : health = blueprint.maxHealth,
      super(size: Vector2.all(blueprint.size), anchor: Anchor.center, priority: 10);

  final EnemyBlueprint blueprint;
  double health;

  int _waypointIndex = 1;
  double _bobPhase = Random().nextDouble() * pi * 2;
  late final SpriteComponent _visual;

  Future<Sprite> buildSprite();

  @override
  Future<void> onLoad() async {
    final wp = game.terrainMap.waypoints;
    position = Vector2(wp.first.x, wp.first.y);
    _visual = SpriteComponent(
      sprite: await buildSprite(),
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    await add(_visual);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState.status != GameStatus.playing) return;

    final wp = game.terrainMap.waypoints;
    if (_waypointIndex >= wp.length) return;

    final target = Vector2(
      wp[_waypointIndex].x,
      wp[_waypointIndex].y,
    );
    final toTarget = target - position;
    final dist = toTarget.length;
    final step = blueprint.speed * dt;

    if (dist <= step) {
      position.setFrom(target);
      _waypointIndex++;
      if (_waypointIndex >= wp.length) {
        _escape();
        return;
      }
    } else {
      final dir = toTarget / dist;
      position += dir * step;
      _visual.angle = atan2(dir.y, dir.x) + pi / 2;
    }

    _bobPhase += dt * 10;
    _visual.position = size / 2 + Vector2(0, sin(_bobPhase) * 1.5);
  }

  void takeDamage(double amount) {
    if (isRemoving) return;
    health -= amount;
    if (health <= 0) _die();
  }

  void _die() {
    final reward = blueprint.bounty + (game.gameState.currentWave - 1) * 2;
    game.gameState.addGold(reward);
    game.audioRepository.play(SfxType.enemyDeath, volume: 0.5);
    game.audioRepository.play(SfxType.goldGain, volume: 0.35);
    game.world.spawn(
      FloatingTextComponent(
        text: '+${reward}g',
        position: position.clone() + Vector2(0, -size.y / 2 - 4),
      ),
    );
    game.world.removeEnemy(this);
  }

  void _escape() {
    game.gameState.damagePlayer(1);
    game.audioRepository.play(SfxType.enemyEscape, volume: 0.5);
    game.world.removeEnemy(this);
  }

  @override
  void render(Canvas canvas) {
    if (health >= blueprint.maxHealth) return;
    final ratio = (health / blueprint.maxHealth).clamp(0.0, 1.0);
    final barWidth = size.x * 0.8;
    final barX = (size.x - barWidth) / 2;
    const barY = -8.0;
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth, 4),
      Paint()..color = const Color(0xAA000000),
    );
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth * ratio, 4),
      Paint()
        ..color = ratio > 0.5
            ? const Color(0xFF4CAF50)
            : const Color(0xFFE53935),
    );
  }
}
