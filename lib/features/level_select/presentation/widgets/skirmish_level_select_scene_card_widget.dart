import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../theme/app_theme/app_theme_borders.dart';
import '../../../../theme/app_theme/app_theme_colors.dart';
import '../../../../theme/app_theme/app_theme_paddings.dart';
import '../../../../theme/app_theme/app_theme_spacing.dart';
import '../../../game_core/domain/models/game_scene.dart';
import '../../../terrain/extensions/biome_extensions.dart';
import '../biome_preview.dart';

/// A featured skirmish scene tile in [SkirmishLevelSelectPage] - live
/// terrain preview plus name/briefing, tap to open placement.
class SkirmishLevelSelectSceneCardWidget extends StatelessWidget {
  final GameScene scene;

  const SkirmishLevelSelectSceneCardWidget({super.key, required this.scene});

  @override
  Widget build(BuildContext context) {
    final palette = scene.biome.palette;
    return Material(
      color: AppThemeColors.transparent,
      child: InkWell(
        borderRadius: AppThemeBorders.radius14,
        onTap: () => context.push(
          Routes.skirmishPlacement.route,
          extra: SkirmishPlacementArgs(scene: scene),
        ),
        child: ClipRRect(
          borderRadius: AppThemeBorders.radius14,
          child: Stack(
            fit: StackFit.expand,
            children: [
              BiomePreview(scene: scene),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppThemeColors.cardOverlayTop,
                      AppThemeColors.cardOverlayBottomStrong,
                    ],
                  ),
                  border: Border.all(
                    color: palette.ridgeLight.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Padding(
                padding: AppThemePaddings.all16,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        scene.name,
                        style: const TextStyle(
                          color: AppThemeColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppThemeSpacing.space4),
                      Text(
                        scene.briefing,
                        style: const TextStyle(
                          color: AppThemeColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
