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

/// Floating action card shown above the command bar whenever a tower is
/// selected on the battlefield - lets the player repair, upgrade, or sell it.
class TowerActionPanel extends StatefulWidget {
  final BoomspireGame game;

  const TowerActionPanel({super.key, required this.game});

  @override
  State<TowerActionPanel> createState() => _TowerActionPanelState();
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.color = Colors.lightBlueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xB31A1F26),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(height: 2),
              _AnimatedLabel(
                label: label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades/slides a label in whenever its text changes - used so cost/state
/// text in the action panel (gold costs, "MAX", "Active"...) doesn't just
/// snap when the underlying tower stat changes.
class _AnimatedLabel extends StatelessWidget {
  final String label;
  final TextStyle style;

  const _AnimatedLabel({required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Text(label, key: ValueKey(label), style: style),
    );
  }
}

class _TowerActionPanelState extends State<TowerActionPanel> {
  Timer? _ticker;

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
                  listenable: widget.game.gameState,
                  builder: (context, _) => _buildCard(tower),
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // The selected tower's HP changes continuously from combat (a Flame
    // component, not a Listenable) - poll at a modest rate so the card
    // stays live without wiring a full ChangeNotifier through it.
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (widget.game.selectedTower.value != null && mounted) setState(() {});
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
            _AnimatedLabel(
              label:
                  'HP ${tower.hp.ceil()}/${tower.maxHp.ceil()}'
                  '${tower.upgradeLevel > 0 ? '  •  ${S.current.towerTier(tower.upgradeLevel + 1)}' : ''}',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.build,
          label: tower.repairCost > 0 ? '${tower.repairCost}g' : '-',
          enabled:
              tower.repairCost > 0 &&
              widget.game.gameState.gold >= tower.repairCost,
          onTap: widget.game.repairSelectedTower,
        ),
        const SizedBox(width: 6),
        _ActionButton(
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
        _ActionButton(
          icon: Icons.gpp_good,
          label: tower.antiRocket ? 'Active' : '${kAntiRocketCost}g',
          color: Colors.cyanAccent,
          enabled:
              !tower.antiRocket &&
              widget.game.gameState.gold >= kAntiRocketCost,
          onTap: widget.game.buyAntiRocketForSelectedTower,
        ),
        const SizedBox(width: 6),
        _ActionButton(
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
          _ActionButton(
            icon: Icons.directions_walk,
            label: ready
                ? '${tower.soldierCost}g'
                : '${tower.cooldownRemaining.ceil()}s',
            color: const Color(0xFF66BB6A),
            enabled: ready && gold >= tower.soldierCost,
            onTap: () => tower.produceSoldier(),
          ),
        ],
      );
    }
    if (tower is WarFactoryComponent) {
      final ready = tower.canProduce;
      final buildableKinds = widget.game.unitRepository
          .kindsFor(widget.game.playerTeam)
          .where((type) => type != UnitKind.soldier);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final type in buildableKinds) ...[
            _ActionButton(
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

  /// Row shown under a Gold Mine's stats - the countdown/amount for its
  /// next passive payout, and the flat bonus it's currently adding to
  /// every kill-gold reward.
  Widget _buildGoldMineRow(GoldMineComponent tower) {
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        _StatChip(
          icon: Icons.paid,
          label: S.current.goldMinePayoutIn(
            tower.payoutAmount,
            tower.payoutTimeRemaining.ceil(),
          ),
          color: const Color(0xFFFFB300),
        ),
        _StatChip(
          icon: Icons.local_fire_department,
          label: S.current.goldMineKillBonus(
            (tower.killGoldBonus * 100).round(),
          ),
          color: const Color(0xFFFF8A65),
        ),
      ],
    );
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
    _ => Icons.directions_walk,
  };
}

/// Small icon+text pill for a passive stat readout - used by the Gold
/// Mine's row since it has no action button, just information.
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xB31A1F26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
