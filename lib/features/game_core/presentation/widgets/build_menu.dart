import 'package:flutter/material.dart';

import '../../../towers/domain/models/tower_blueprint.dart';
import '../../../towers/domain/models/tower_type.dart';
import '../circuit_defense_game.dart';

/// Bottom build bar: pick a tower type, then tap an empty pad on the field
/// to place it (costs gold, needs a free build slot).
class BuildMenu extends StatelessWidget {
  const BuildMenu({super.key, required this.game});

  final CircuitDefenseGame game;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ListenableBuilder(
        listenable: game.gameState,
        builder: (context, _) {
          return ValueListenableBuilder<TowerType?>(
            valueListenable: game.selectedTowerType,
            builder: (context, selected, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: game.towerRepository.all.map((bp) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _TowerButton(
                      blueprint: bp,
                      selected: selected == bp.type,
                      enabled: game.gameState.gold >= bp.cost,
                      onTap: () => game.selectTowerType(bp.type),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

class _TowerButton extends StatelessWidget {
  const _TowerButton({
    required this.blueprint,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final TowerBlueprint blueprint;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = blueprint.type.name == 'rocket'
        ? const Color(0xFFFF6B35)
        : const Color(0xFF4FC3F7);
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 108,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accent : Colors.white24,
              width: selected ? 2.5 : 1,
            ),
            boxShadow: selected
                ? [BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 12)]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                blueprint.type.name == 'rocket'
                    ? Icons.local_fire_department
                    : Icons.gps_fixed,
                color: accent,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                blueprint.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${blueprint.cost}g',
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 12,
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
