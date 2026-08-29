import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';
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
      borderRadius: AppThemeBorders.radius14,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: AppThemePaddings.h12v8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: AppThemeBorders.radius14,
            border: Border.all(color: AppThemeColors.borderSubtle),
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
                SizedBox(width: AppThemeSpacing.space6),
                GameCoreBuildMenuTabWidget(
                  label: S.current.buildMenuBuildingsTab,
                  selected: showBuildings,
                  onTap: () => _showBuildings.value = true,
                ),
              ],
            ),
            SizedBox(height: AppThemeSpacing.space6),
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
                        // Default layoutBuilder stacks children centered,
                        // which makes the crossfade appear to grow from the
                        // middle instead of staying pinned to the start.
                        layoutBuilder: (currentChild, previousChildren) =>
                            Stack(
                              alignment: AlignmentDirectional.centerStart,
                              children: [...previousChildren, ?currentChild],
                            ),
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
                            children: entries
                                .map((bp) {
                                  final lockReason = game.buildBlockReason(
                                    bp.type,
                                  );
                                  final affordable =
                                      game.gameState.gold >= bp.cost;
                                  return Padding(
                                    padding: AppThemePaddings.h4,
                                    child: GameCoreBuildMenuTowerButtonWidget(
                                      blueprint: bp,
                                      selected: selected == bp.type,
                                      enabled: affordable && lockReason == null,
                                      lockReason: lockReason,
                                      builtCount: game.towerCountFor(bp.type),
                                      limit: game.buildLimitFor(bp.type),
                                      onTap: () =>
                                          game.selectTowerType(bp.type),
                                    ),
                                  );
                                })
                                .toList()
                                .animate(
                                  effects: [
                                    FadeEffect(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      curve: Curves.easeOut,
                                    ),
                                    SlideEffect(
                                      begin: const Offset(0, 0.08),
                                      end: Offset.zero,
                                      duration: const Duration(
                                        milliseconds: 420,
                                      ),
                                      curve: Curves.easeOut,
                                    ),

                                    ScaleEffect(
                                      begin: const Offset(0.1, 0.1),
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      curve: Curves.easeOut,
                                    ),
                                  ],
                                ),
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
