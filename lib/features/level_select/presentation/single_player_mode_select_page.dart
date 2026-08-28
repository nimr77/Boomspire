import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/widgets/hover_scale_card.dart';
import '../../../core/widgets/menu_option_content.dart';
import '../../../core/widgets/window_controls.dart';
import '../../../generated/l10n.dart';
import '../../../theme/app_theme/app_theme_colors.dart';
import '../../../theme/app_theme/app_theme_paddings.dart';
import '../../../theme/app_theme/app_theme_spacing.dart';

/// Single Player drill-down: choose Tower Defense (the original wave
/// survival campaigns) or Skirmish (home-vs-home battles against the AI),
/// each leading to its own map/scene listing.
class SinglePlayerModeSelectPage extends StatelessWidget {
  const SinglePlayerModeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: AppThemePaddings.h16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                            S.current.modeSelectTitle,
                            style: const TextStyle(
                              color: AppThemeColors.textPrimary,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 360.ms)
                          .slideY(begin: -0.2, end: 0),
                      const SizedBox(height: AppThemeSpacing.space6),
                      Text(
                            S.current.modeSelectSubtitle,
                            style: const TextStyle(
                              color: AppThemeColors.textSecondary,
                              fontSize: 15,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 360.ms, delay: 60.ms)
                          .slideY(begin: -0.2, end: 0),
                      const SizedBox(height: AppThemeSpacing.space32),
                      HoverScaleCard(
                            accentColor: AppThemeColors.accentOrange,
                            onTap: () => context.push(
                              Routes.towerDefenseLevelSelect.route,
                            ),
                            child: MenuOptionContent(
                              icon: Icons.shield,
                              title: S.current.modeTowerDefenseTitle,
                              subtitle: S.current.modeTowerDefenseSubtitle,
                              accentColor: AppThemeColors.accentOrange,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 360.ms, delay: 140.ms)
                          .scale(
                            begin: const Offset(0.94, 0.94),
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: AppThemeSpacing.space18),
                      HoverScaleCard(
                            accentColor: AppThemeColors.accentRed,
                            onTap: () =>
                                context.push(Routes.skirmishLevelSelect.route),
                            child: MenuOptionContent(
                              icon: Icons.swap_horiz,
                              title: S.current.modeSkirmishTitle,
                              subtitle: S.current.modeSkirmishSubtitle,
                              accentColor: AppThemeColors.accentRed,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 360.ms, delay: 220.ms)
                          .scale(
                            begin: const Offset(0.94, 0.94),
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(child: const WindowControls()),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: AppThemeColors.glassPill,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppThemeColors.borderSubtle),
                ),
                child: IconButton(
                  tooltip: S.current.backTooltip,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppThemeColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
