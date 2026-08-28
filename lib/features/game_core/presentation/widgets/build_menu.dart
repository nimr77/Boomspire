import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../towers/domain/models/building_type.dart';
import '../../../towers/domain/models/unit_type.dart';
import '../boomspire_game.dart';
import 'game_core_build_menu_tab_widget.dart';
import 'game_core_build_menu_tower_button_widget.dart';

/// The frosted-glass Towers/Buildings placement picker docked at the right
/// end of the bottom command bar (see [HudOverlay]). A selected tower's own
/// info/actions/produce-unit menu lives in [GameCoreEntityPanelWidget]
/// instead, right next to the minimap - this panel is placement-only.
class BuildMenu extends StatefulWidget {
  final BoomspireGame game;

  const BuildMenu({super.key, required this.game});

  @override
  State<BuildMenu> createState() => _BuildMenuState();
}

class _BuildMenuState extends State<BuildMenu> {
  final ValueNotifier<bool> _showBuildings = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: _buildPlacementMenu(game),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _showBuildings.dispose();
    super.dispose();
  }

  Widget _buildPlacementMenu(BoomspireGame game) {
    return ValueListenableBuilder<bool>(
      valueListenable: _showBuildings,
      builder: (context, showBuildings, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The tab strip sits directly on top of the button panel below,
            // as one cohesive menu, rather than stealing its own separate row.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GameCoreBuildMenuTabWidget(
                  label: S.current.buildMenuTowersTab,
                  selected: !showBuildings,
                  onTap: () => _showBuildings.value = false,
                ),
                const SizedBox(width: 6),
                GameCoreBuildMenuTabWidget(
                  label: S.current.buildMenuBuildingsTab,
                  selected: showBuildings,
                  onTap: () => _showBuildings.value = true,
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Kept at its original, unshrunk size - the tabs above animate
            // their own height instead of squeezing this row.
            SizedBox(
              height: 90,
              child: ListenableBuilder(
                listenable: game.gameState,
                builder: (context, _) {
                  return ValueListenableBuilder<UnitType?>(
                    valueListenable: game.selectedTowerType,
                    builder: (context, selected, _) {
                      final entries =
                          [
                                ...game.towerRepository.all,
                                ...game.buildingRepository.all,
                              ]
                              .where(
                                (bp) =>
                                    (bp.type is BuildingType) == showBuildings,
                              )
                              .toList();
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: SingleChildScrollView(
                          key: ValueKey(showBuildings),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: entries.map((bp) {
                              final lockReason = game.buildBlockReason(bp.type);
                              final affordable = game.gameState.gold >= bp.cost;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: GameCoreBuildMenuTowerButtonWidget(
                                  blueprint: bp,
                                  selected: selected == bp.type,
                                  enabled: affordable && lockReason == null,
                                  lockReason: lockReason,
                                  builtCount: game.towerCountFor(bp.type),
                                  limit: game.buildLimitFor(bp.type),
                                  onTap: () => game.selectTowerType(bp.type),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
