import 'package:boomspire/shared/widgets/mesh_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/widgets/hover_scale_card.dart';
import '../../../core/widgets/menu_option_content.dart';
import '../../../core/widgets/window_controls.dart';
import '../../../generated/l10n.dart';
import '../../../shared/app_theme/app_theme_borders.dart';
import '../../../shared/app_theme/app_theme_colors.dart';
import '../../../shared/app_theme/app_theme_paddings.dart';
import '../../../shared/app_theme/app_theme_spacing.dart';

/// The app's true landing page: shows the game's modes first, before any
/// map/campaign list. Currently only "Single Player" is playable (which
/// then drills down into Tower Defense vs Skirmish); the Map Editor is
/// reachable here too since it authors maps for both modes.
class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      body: Stack(
        children: [
          GameMeshBackgroundWidget(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: AppThemePaddings.h16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                            S.current.levelSelectTitle,
                            style: const TextStyle(
                              color: AppThemeColors.textPrimary,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.2, end: 0),
                      const SizedBox(height: AppThemeSpacing.space6),
                      Text(
                            S.current.mainMenuSubtitle,
                            style: const TextStyle(
                              color: AppThemeColors.textSecondary,
                              fontSize: 16,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 80.ms)
                          .slideY(begin: -0.2, end: 0),
                      const SizedBox(height: AppThemeSpacing.space40),
                      HoverScaleCard(
                            accentColor: AppThemeColors.accentCyan,
                            onTap: () => context.push(
                              Routes.singlePlayerModeSelect.route,
                            ),
                            child: MenuOptionContent(
                              icon: Icons.person,
                              title: S.current.mainMenuSinglePlayer,
                              subtitle: S.current.mainMenuSinglePlayerSubtitle,
                              accentColor: AppThemeColors.accentCyan,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 380.ms, delay: 160.ms)
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
                  borderRadius: AppThemeBorders.radius24,
                  border: Border.all(color: AppThemeColors.borderSubtle),
                ),
                child: IconButton(
                  tooltip: S.current.mapEditorTooltip,
                  icon: const Icon(
                    Icons.map_outlined,
                    color: AppThemeColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => context.push(Routes.mapEditorList.route),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
