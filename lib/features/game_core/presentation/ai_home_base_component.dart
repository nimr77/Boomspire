import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/attackable.dart';
import '../../../core/combat/team.dart';
import '../../../core/combat/unit.dart';
import '../domain/models/game_status.dart';
import 'boomspire_game.dart';
import 'home_base_sprite.dart';
import 'util/paint_home_base.dart';

/// The AI opponent's home base in a [GameMode.skirmish] match - the mirror
/// of [HomeBaseComponent] (same shared art, just tinted in the AI's own
/// team color), backed by [BoomspireGame.aiEconomy] instead of the human
/// player's [GameStateRepository]. Destroying it wins the match for the
/// player (see [takeDamage]).
class AiHomeBaseComponent extends PositionComponent
    with HasGameReference<BoomspireGame>, Unit
    implements Attackable {
  late final SpriteComponent _visual;
  int _lastHealth = 0;
  double _pulse = 0;

  AiHomeBaseComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2.all(84),
        anchor: Anchor.center,
        priority: 6,
      );

  @override
  Set<UnitDomain> get attackDomains => const {};

  @override
  bool get destroyed => game.aiEconomy?.isDefeated ?? true;

  @override
  UnitDomain get domain => UnitDomain.ground;

  @override
  double get health => (game.aiEconomy?.health ?? 0).toDouble();

  @override
  double get healthRatio {
    final economy = game.aiEconomy;
    if (economy == null) return 0;
    return (economy.health / economy.maxHealth).clamp(0.0, 1.0);
  }

  Team get owner => game.aiTeam ?? Team.aiOpponent;

  @override
  Future<void> onLoad() async {
    _lastHealth = game.aiEconomy?.health ?? 0;
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
  void render(Canvas canvas) {
    paintHomeBase(
      canvas,
      size: size,
      pulse: _pulse,
      healthRatio: healthRatio,
      ownerColor: owner.color,
    );
  }

  @override
  void takeDamage(double amount) {
    final economy = game.aiEconomy;
    if (economy == null || economy.isDefeated) return;
    economy.damageBase(amount.round());
    if (economy.isDefeated) {
      game.gameState.setStatus(GameStatus.victory);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final health = game.aiEconomy?.health ?? 0;
    if (health < _lastHealth) _pulse = 1;
    _lastHealth = health;
    if (_pulse > 0) _pulse = (_pulse - dt * 1.6).clamp(0, 1);
  }
}
