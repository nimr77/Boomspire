import 'package:flame/components.dart';

import '../../../core/combat/attackable.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../enemies/presentation/floating_text_component.dart';
import '../../game_core/domain/models/game_config.dart';
import 'tower_component.dart';

/// Non-combat structure: it never fires (zero range/damage). Instead it
/// passively pays out gold every `GameConfig.goldMineTickInterval` seconds
/// and boosts every kill-gold reward earned while it stands (see
/// `BoomspireGame.goldMineKillGoldBonus`) - both effects rise with
/// [TowerComponent.upgradeLevel], same as combat towers' repair-then-upgrade
/// path.
class GoldMineComponent extends TowerComponent {
  double _payoutTimer = GameConfig.goldMineTickInterval;

  GoldMineComponent({
    required super.position,
    required super.cellSize,
    required super.blueprint,
  });

  /// Extra fraction added on top of every kill-gold reward while this mine
  /// stands - rises by one more full base bonus per upgrade tier.
  double get killGoldBonus =>
      GameConfig.goldMineBaseKillGoldBonus * (1 + upgradeLevel);

  /// Passive gold paid out every `GameConfig.goldMineTickInterval` seconds -
  /// rises by one more full base payout per upgrade tier.
  int get payoutAmount =>
      GameConfig.goldMineBaseGoldPerTick * (1 + upgradeLevel);

  /// Seconds remaining until the next passive payout - shown in the tower
  /// action panel.
  double get payoutTimeRemaining => _payoutTimer;

  @override
  void fire(Attackable target) {}

  @override
  void update(double dt) {
    super.update(dt);
    if (destroyed) return;
    _payoutTimer -= dt;
    if (_payoutTimer <= 0) {
      _payoutTimer += GameConfig.goldMineTickInterval;
      game.gameState.addGold(payoutAmount);
      game.audioRepository.play(SfxType.goldGain, volume: 0.3);
      game.world.spawn(
        FloatingTextComponent(
          text: '+${payoutAmount}g',
          position: position.clone() + Vector2(0, -size.y / 2 - 4),
        ),
      );
    }
  }
}
