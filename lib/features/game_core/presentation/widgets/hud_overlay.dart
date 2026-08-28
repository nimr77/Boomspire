import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../generated/l10n.dart';
import '../../domain/models/game_scene.dart';
import '../boomspire_game.dart';
import 'build_menu.dart';
import 'game_core_entity_panel_widget.dart';
import 'game_core_hud_stat_chip_widget.dart';
import 'minimap_widget.dart';

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
          ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    // Tall enough for the build menu's tab strip *plus* its
                    // original full-size tower/building buttons underneath.
                    height: 146,
                    decoration: const BoxDecoration(
                      color: Color(0xCC12161C),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GameCoreHudStatChipWidget(
                                    icon: Icons.favorite,
                                    color: Colors.redAccent,
                                    label: '${game.gameState.health}',
                                  ),
                                  GameCoreHudStatChipWidget(
                                    icon: Icons.monetization_on,
                                    color: Colors.amberAccent,
                                    label: '${game.gameState.gold}',
                                  ),
                                  GameCoreHudStatChipWidget(
                                    icon: Icons.military_tech,
                                    color: Colors.cyanAccent,
                                    label: '${game.gameState.currentScore}',
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: MinimapWidget(game: game),
                        ),
                        // The selected tower/unit's info+actions (and its
                        // produce-unit buttons, if it's a producer) - right
                        // next to the minimap, collapses to nothing when
                        // there's no selection.
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          child: GameCoreEntityPanelWidget(game: game),
                        ),
                        // Wave-defense shows its own compact progress label;
                        // skirmish has no equivalent single number, so it
                        // shows nothing here rather than a stale/odd stat.
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: ListenableBuilder(
                            listenable: game.gameState,
                            builder: (context, _) {
                              if (game.scene.mode == GameMode.skirmish) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                S.current.hudWaveLabel(
                                  game.gameState.currentWave,
                                  game.gameState.totalWaves,
                                ),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              );
                            },
                          ),
                        ),
                        // The one panel with real growth priority - towers,
                        // buildings, and unit production all need the room.
                        Expanded(child: BuildMenu(game: game)),
                      ],
                    ),
                  ),
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
