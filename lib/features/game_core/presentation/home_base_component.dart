import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../../../core/combat/attackable.dart';
import '../../../core/combat/team.dart';
import '../../../core/combat/unit.dart';
import '../domain/models/game_config.dart';
import 'boomspire_game.dart';
import 'home_base_sprite.dart';

/// The player's home base at the terrain's end point: a defended structure
/// (instead of a plain marker circle) that shows its remaining health and
/// flashes/pulses red whenever the player takes damage. Implements
/// [Attackable] so a [GameMode.skirmish] opponent's units can walk up and
/// destroy it directly, same as they would a tower - its actual HP still
/// lives in [GameStateRepository.health] (the single human player's wallet),
/// not on this component.
class HomeBaseComponent extends PositionComponent
    with HasGameReference<BoomspireGame>, Unit
    implements Attackable {
  /// Always the human player's team today - kept as a field (rather than
  /// just reading `game.playerTeam`) so `opposingTargets()` can treat this
  /// the same way it treats an owned tower.
  final Team owner;

  late final SpriteComponent _visual;
  int _lastHealth = 0;
  double _pulse = 0;

  HomeBaseComponent({
    required Vector2 position,
    this.owner = Team.defaultPlayer,
  }) : super(
         position: position,
         size: Vector2.all(84),
         anchor: Anchor.center,
         priority: 6,
       );

  @override
  Set<UnitDomain> get attackDomains => const {};

  @override
  bool get destroyed => game.gameState.health <= 0;

  @override
  UnitDomain get domain => UnitDomain.ground;

  @override
  double get healthRatio =>
      (game.gameState.health / GameConfig.startingHealth).clamp(0.0, 1.0);

  @override
  Future<void> onLoad() async {
    _lastHealth = game.gameState.health;
    final image = await HomeBaseSprite.forTeam(owner);
    _visual = SpriteComponent(
      sprite: Sprite(image),
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    await add(_visual);
  }

  @override
  void render(ui.Canvas canvas) {
    if (_pulse > 0) {
      final radius = size.x * (0.55 + (1 - _pulse) * 0.55);
      canvas.drawCircle(
        ui.Offset(size.x / 2, size.y / 2),
        radius,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = const ui.Color(0xFFE53935).withValues(alpha: _pulse * 0.85),
      );
    }

    final ratio = (game.gameState.health / GameConfig.startingHealth).clamp(
      0.0,
      1.0,
    );
    final barWidth = size.x * 0.9;
    final barX = (size.x - barWidth) / 2;
    const barY = -12.0;
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(barX, barY, barWidth, 6),
        const ui.Radius.circular(3),
      ),
      ui.Paint()..color = const ui.Color(0xAA000000),
    );
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(barX, barY, barWidth * ratio, 6),
        const ui.Radius.circular(3),
      ),
      ui.Paint()
        ..color = ratio > 0.4 ? owner.color : const ui.Color(0xFFE53935),
    );
  }

  @override
  void takeDamage(double amount) => game.gameState.damagePlayer(amount.round());

  @override
  void update(double dt) {
    super.update(dt);
    final health = game.gameState.health;
    if (health < _lastHealth) _pulse = 1;
    _lastHealth = health;
    if (_pulse > 0) _pulse = (_pulse - dt * 1.6).clamp(0, 1);
  }
}
