import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../generated/l10n.dart';
import '../../../../theme/app_theme/app_theme_colors.dart';
import '../../../../theme/app_theme/app_theme_paddings.dart';
import '../../../../theme/app_theme/app_theme_spacing.dart';
import '../../../game_core/domain/models/game_difficulty.dart';
import '../../../game_core/domain/models/game_scene.dart';
import '../../../progress/domain/models/progress_snapshot.dart';
import '../../../terrain/extensions/biome_extensions.dart';
import '../biome_preview.dart';

/// One campaign scene tile in the [LevelSelectPage] grid - live terrain
/// preview, completion badge, wave count/best-wave stats, tap to launch.
class LevelSelectSceneCardWidget extends StatelessWidget {
  final GameScene scene;
  final ProgressSnapshot progress;
  final GameDifficulty difficulty;
  final Future<void> Function() onReturn;

  const LevelSelectSceneCardWidget({
    super.key,
    required this.scene,
    required this.progress,
    required this.difficulty,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final palette = scene.biome.palette;
    final completed = progress.isCompleted(scene.id);
    final bestWave = progress.bestWaveFor(scene.id);
    return Material(
      color: AppThemeColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await context.push(
            Routes.game.route,
            extra: GameRouteArgs(scene: scene, difficulty: difficulty),
          );
          await onReturn();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'scene-preview-${scene.id}',
                child: BiomePreview(scene: scene),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GlassmorphicContainer(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    borderRadius: 14,
                    blur: 6,
                    border: 1.5,
                    linearGradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppThemeColors.cardOverlayTop,
                        AppThemeColors.cardOverlayBottom,
                      ],
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        palette.ridgeLight.withValues(alpha: 0.7),
                        palette.ridgeLight.withValues(alpha: 0.2),
                      ],
                    ),
                    child: Padding(
                      padding: AppThemePaddings.all16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (completed)
                            Container(
                              margin: AppThemePaddings.bottom6,
                              padding: AppThemePaddings.h8v2,
                              decoration: BoxDecoration(
                                color: AppThemeColors.accentGreen.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppThemeColors.accentGreen,
                                ),
                              ),
                              child: Text(
                                S.current.sceneCompleted,
                                style: const TextStyle(
                                  color: AppThemeColors.accentGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
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
                          const SizedBox(height: AppThemeSpacing.space8),
                          Row(
                            spacing: AppThemeSpacing.space10,
                            children: [
                              Text(
                                S.current.wavesCount(scene.waveCount),
                                style: TextStyle(
                                  color: palette.ridgeLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              if (bestWave > 0)
                                Text(
                                  S.current.bestWaveReached(bestWave),
                                  style: const TextStyle(
                                    color: AppThemeColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
