import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/combat/unit_kind.dart';
import '../../../../generated/l10n.dart';
import '../../../towers/presentation/gold_mine_component.dart';
import '../../../towers/presentation/tower_component.dart';
import '../../../towers/presentation/tower_sprites.dart';
import '../../../towers/presentation/training_center_component.dart';
import '../../../towers/presentation/war_factory_component.dart';
import '../boomspire_game.dart';
import 'game_core_tower_action_animated_label_widget.dart';
import 'game_core_tower_action_button_widget.dart';
import 'game_core_tower_action_stat_chip_widget.dart';

/// Floating action card shown above the command bar whenever a tower is
/// selected on the battlefield - lets the player repair, upgrade, or sell it.
class TowerActionPanel extends StatefulWidget {
  final BoomspireGame game;

  const TowerActionPanel({super.key, required this.game});

  @override
  State<TowerActionPanel> createState() => _TowerActionPanelState();
}

class _TowerActionPanelState extends State<TowerActionPanel> {
  Timer? _pollTimer;
  final ValueNotifier<int> _tick = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TowerComponent?>(
      valueListenable: widget.game.selectedTower,
      builder: (context, tower, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
          child: tower == null
              ? const SizedBox.shrink(key: ValueKey('no-tower-selected'))
              : ListenableBuilder(
                  key: ValueKey(tower),
                  listenable: Listenable.merge([widget.game.gameState, _tick]),
                  builder: (context, _) => _buildCard(tower),
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _tick.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // The selected tower's HP changes continuously from combat (a Flame
    // component, not a Listenable) - poll at a modest rate so the card
    // stays live without wiring a full ChangeNotifier through it.
    _pollTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (widget.game.selectedTower.value != null && mounted) _tick.value++;
    });
  }

  Widget _buildCard(TowerComponent tower) {
    final accent = TowerSpriteFactory.accentColor(tower.blueprint.type);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xF00F1216),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 12),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow(tower, accent),
          if (tower is TrainingCenterComponent ||
              tower is WarFactoryComponent) ...[
            const SizedBox(height: 8),
            _buildUnitRow(tower),
          ],
          if (tower is GoldMineComponent) ...[
            const SizedBox(height: 8),
            _buildGoldMineRow(tower),
          ],
        ],
      ),
    );
  }

  /// Row shown under a Gold Mine's stats - the countdown/amount for its
  /// next passive payout, and the flat bonus it's currently adding to
  /// every kill-gold reward.
  Widget _buildGoldMineRow(GoldMineComponent tower) {
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        GameCoreTowerActionStatChipWidget(
          icon: Icons.paid,
          label: S.current.goldMinePayoutIn(
            tower.payoutAmount,
            tower.payoutTimeRemaining.ceil(),
          ),
          color: const Color(0xFFFFB300),
        ),
        GameCoreTowerActionStatChipWidget(
          icon: Icons.local_fire_department,
          label: S.current.goldMineKillBonus(
            (tower.killGoldBonus * 100).round(),
          ),
          color: const Color(0xFFFF8A65),
        ),
      ],
    );
  }

  Widget _buildStatRow(TowerComponent tower, Color accent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tower.blueprint.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            GameCoreTowerActionAnimatedLabelWidget(
              label:
                  'HP ${tower.hp.ceil()}/${tower.maxHp.ceil()}'
                  '${tower.upgradeLevel > 0 ? '  •  ${S.current.towerTier(tower.upgradeLevel + 1)}' : ''}',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(width: 12),
        GameCoreTowerActionButtonWidget(
          icon: Icons.build,
          label: tower.repairCost > 0 ? '${tower.repairCost}g' : '-',
          enabled:
              tower.repairCost > 0 &&
              widget.game.gameState.gold >= tower.repairCost,
          onTap: widget.game.repairSelectedTower,
        ),
        const SizedBox(width: 6),
        GameCoreTowerActionButtonWidget(
          icon: Icons.upgrade,
          label: tower.canUpgrade
              ? '${tower.upgradeCost}g'
              : S.current.towerMax,
          enabled:
              tower.canUpgrade &&
              widget.game.gameState.gold >= tower.upgradeCost,
          onTap: widget.game.upgradeSelectedTower,
        ),
        const SizedBox(width: 6),
        GameCoreTowerActionButtonWidget(
          icon: Icons.gpp_good,
          label: tower.antiRocket ? 'Active' : '${kAntiRocketCost}g',
          color: Colors.cyanAccent,
          enabled:
              !tower.antiRocket &&
              widget.game.gameState.gold >= kAntiRocketCost,
          onTap: widget.game.buyAntiRocketForSelectedTower,
        ),
        const SizedBox(width: 6),
        GameCoreTowerActionButtonWidget(
          icon: Icons.sell,
          label: '+${tower.sellValue}g',
          enabled: true,
          color: Colors.redAccent,
          onTap: widget.game.sellSelectedTower,
        ),
        const SizedBox(width: 6),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white54, size: 18),
          onPressed: () => widget.game.selectedTower.value = null,
        ),
      ],
    );
  }

  /// Second row shown under a Training Center/War Factory's stats - lets
  /// the player spend gold to muster/roll out a specific ally unit, in
  /// place of what used to be automatic, timer-driven production.
  Widget _buildUnitRow(TowerComponent tower) {
    final gold = widget.game.gameState.gold;
    if (tower is TrainingCenterComponent) {
      final ready = tower.canProduce;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final kind in TrainingCenterComponent.producibleKinds) ...[
            GameCoreTowerActionButtonWidget(
              icon: _unitIcon(kind),
              label: ready
                  ? '${tower.costFor(kind)}g'
                  : '${tower.cooldownRemaining.ceil()}s',
              color: const Color(0xFF66BB6A),
              enabled: ready && gold >= tower.costFor(kind),
              onTap: () => tower.produceUnit(kind),
            ),
            const SizedBox(width: 6),
          ],
        ],
      );
    }
    if (tower is WarFactoryComponent) {
      final ready = tower.canProduce;
      final buildableKinds = widget.game.unitRepository
          .kindsFor(widget.game.playerTeam)
          .where(
            (type) => !TrainingCenterComponent.producibleKinds.contains(type),
          );
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final type in buildableKinds) ...[
            GameCoreTowerActionButtonWidget(
              icon: _unitIcon(type),
              label: ready
                  ? '${tower.costFor(type)}g'
                  : '${tower.cooldownRemaining.ceil()}s',
              color: const Color(0xFFB0BEC5),
              enabled: ready && gold >= tower.costFor(type),
              onTap: () => tower.produceUnit(type),
            ),
            const SizedBox(width: 6),
          ],
        ],
      );
    }
    return const SizedBox.shrink();
  }

  IconData _unitIcon(UnitKind type) => switch (type) {
    UnitKind.tank => Icons.local_shipping,
    UnitKind.lightVehicle => Icons.directions_car,
    UnitKind.aircraft => Icons.flight,
    UnitKind.rocketBarrage => Icons.rocket_launch,
    UnitKind.heavySoldier => Icons.security,
    UnitKind.helicopter => Icons.airline_seat_recline_extra,
    UnitKind.attackPlane => Icons.flight_takeoff,
    UnitKind.gunboat => Icons.directions_boat,
    UnitKind.artilleryBarrage => Icons.gps_fixed,
    UnitKind.antiTankSoldier => Icons.gps_fixed,
    UnitKind.antiAirSoldier => Icons.arrow_circle_up,
    _ => Icons.directions_walk,
  };
}
