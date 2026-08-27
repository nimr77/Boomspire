import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/attackable.dart';
import '../../../core/combat/team.dart';
import '../../../core/combat/unit.dart';
import '../domain/models/game_status.dart';
import 'boomspire_game.dart';

/// The AI opponent's home base in a [GameMode.skirmish] match - the mirror
/// of [HomeBaseComponent], but backed by [BoomspireGame.aiEconomy] instead
/// of the human player's [GameStateRepository]. Destroying it wins the
/// match for the player (see [takeDamage]).
class AiHomeBaseComponent extends PositionComponent
    with HasGameReference<BoomspireGame>, Unit
    implements Attackable {
  int _lastHealth = 0;
  double _pulse = 0;
  double _idlePhase = 0;

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
  double get healthRatio {
    final economy = game.aiEconomy;
    if (economy == null) return 0;
    return (economy.health / economy.maxHealth).clamp(0.0, 1.0);
  }

  Team get owner => game.aiTeam ?? Team.aiOpponent;

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
  void render(Canvas canvas) {
    final accent = owner.color;
    final center = Offset(size.x / 2, size.y / 2);

    // Base plate + keep silhouette - a simple, readable structure rather
    // than a fancy sprite (the player's home base has its own bespoke art;
    // this reuses the same "flat shape + accent glow" language the rest of
    // the battlefield's structures share).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size.x * 0.8, height: size.y * 0.6),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF20242B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size.x * 0.8, height: size.y * 0.6),
        const Radius.circular(10),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = accent.withValues(alpha: 0.75 + 0.15 * (0.5 + 0.5 * _pulseWave())),
    );
    final breath = 0.5 + 0.5 * _pulseWave();
    canvas.drawCircle(
      center,
      size.x * 0.3 + breath * 2,
      Paint()..color = accent.withValues(alpha: 0.18 + breath * 0.1),
    );

    if (_pulse > 0) {
      final radius = size.x * (0.55 + (1 - _pulse) * 0.55);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = const Color(0xFFE53935).withValues(alpha: _pulse * 0.85),
      );
    }

    final ratio = healthRatio;
    final barWidth = size.x * 0.9;
    final barX = (size.x - barWidth) / 2;
    const barY = -12.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barWidth, 6),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xAA000000),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barWidth * ratio, 6),
        const Radius.circular(3),
      ),
      Paint()..color = ratio > 0.4 ? accent : const Color(0xFFE53935),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _idlePhase += dt;
    final health = game.aiEconomy?.health ?? 0;
    if (health < _lastHealth) _pulse = 1;
    _lastHealth = health;
    if (_pulse > 0) _pulse = (_pulse - dt * 1.6).clamp(0, 1);
  }

  double _pulseWave() {
    final t = _idlePhase * 2.2 % (3.14159265 * 2);
    return t < 3.14159265 ? (t / 3.14159265) : (2 - t / 3.14159265);
  }
}
