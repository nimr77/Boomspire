import 'package:flutter/material.dart';

import '../circuit_defense_game.dart';
import 'build_menu.dart';

/// Top status bar (health/wave/gold) plus the bottom tower build menu.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final CircuitDefenseGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ListenableBuilder(
              listenable: game.gameState,
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatChip(
                      icon: Icons.favorite,
                      color: Colors.redAccent,
                      label: '${game.gameState.health}',
                    ),
                    Text(
                      'WAVE ${game.gameState.currentWave} / ${game.gameState.totalWaves}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
                    ),
                    _StatChip(
                      icon: Icons.monetization_on,
                      color: Colors.amberAccent,
                      label: '${game.gameState.gold}',
                    ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: BuildMenu(game: game),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xB31A1F26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
