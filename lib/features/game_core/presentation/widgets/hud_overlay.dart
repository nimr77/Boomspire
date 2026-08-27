import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../generated/l10n.dart';
import '../../domain/models/game_scene.dart';
import '../boomspire_game.dart';
import 'build_menu.dart';

/// Bottom-docked command bar (health/gold/wave + construction menu), C&C
/// Generals-style. Placed as a normal sibling below the [GameWidget] (see
/// [GamePage]) - not a floating overlay on top of it - so the arena never
/// renders underneath it and the home base (which can be placed anywhere)
/// stays fully visible.
class HudOverlay extends StatelessWidget {
  final BoomspireGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child:
          Container(
                // Tall enough for the build menu's tab strip *plus* its
                // original full-size tower/building buttons underneath.
                height: 146,
                decoration: const BoxDecoration(
                  color: Color(0xE60F1216),
                  border: Border(
                    top: BorderSide(color: Color(0xFF2A323C), width: 2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: ListenableBuilder(
                        listenable: game.gameState,
                        builder: (context, _) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatChip(
                                icon: Icons.favorite,
                                color: Colors.redAccent,
                                label: '${game.gameState.health}',
                              ),
                              _StatChip(
                                icon: Icons.monetization_on,
                                color: Colors.amberAccent,
                                label: '${game.gameState.gold}',
                              ),
                              _StatChip(
                                icon: Icons.military_tech,
                                color: Colors.cyanAccent,
                                label: '${game.gameState.currentScore}',
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ListenableBuilder(
                          listenable: game.gameState,
                          builder: (context, _) {
                            final aiEconomy = game.aiEconomy;
                            final label =
                                game.scene.mode == GameMode.skirmish &&
                                    aiEconomy != null
                                ? S.current.hudAiBaseLabel(aiEconomy.health)
                                : S.current.hudWaveLabel(
                                    game.gameState.currentWave,
                                    game.gameState.totalWaves,
                                  );
                            return Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                shadows: [
                                  Shadow(blurRadius: 4, color: Colors.black),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    BuildMenu(game: game),
                  ],
                ),
              )
              .animate()
              .slideY(
                begin: 1,
                end: 0,
                duration: 380.ms,
                curve: Curves.easeOutCubic,
              )
              .fadeIn(duration: 280.ms),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;

  final Color color;
  final String label;
  const _StatChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xB31A1F26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
