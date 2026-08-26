import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../towers/presentation/tower_component.dart';
import '../../../towers/presentation/tower_sprites.dart';
import '../circuit_defense_game.dart';

/// Floating action card shown above the command bar whenever a tower is
/// selected on the battlefield - lets the player repair, upgrade, or sell it.
class TowerActionPanel extends StatefulWidget {
  final CircuitDefenseGame game;

  const TowerActionPanel({super.key, required this.game});

  @override
  State<TowerActionPanel> createState() => _TowerActionPanelState();
}

class _TowerActionPanelState extends State<TowerActionPanel> {
  Timer? _ticker;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TowerComponent?>(
      valueListenable: widget.game.selectedTower,
      builder: (context, tower, _) {
        if (tower == null) return const SizedBox.shrink();
        return ListenableBuilder(
          listenable: widget.game.gameState,
          builder: (context, _) {
            final accent = TowerSpriteFactory.accentColor(tower.blueprint.type);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xF00F1216),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.6)),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
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
                      Text(
                        'HP ${tower.hp.ceil()}/${tower.maxHp.ceil()}'
                        '${tower.upgradeLevel > 0 ? '  •  ${S.current.towerTier(tower.upgradeLevel + 1)}' : ''}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
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
                    icon: Icons.sell,
                    label: '+${tower.sellValue}g',
                    enabled: true,
                    color: Colors.redAccent,
                    onTap: widget.game.sellSelectedTower,
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white54,
                      size: 18,
                    ),
                    onPressed: () => widget.game.selectedTower.value = null,
                  ),
                ],
              ),
            );
          },
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
              Text(
                label,
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
