import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/widgets/window_controls.dart';
import '../../../generated/l10n.dart';
import '../../../theme/app_theme/app_theme_colors.dart';
import '../../../theme/app_theme/app_theme_paddings.dart';
import '../../../theme/app_theme/app_theme_spacing.dart';
import '../../account/presentation/account_badge.dart';
import '../../account/presentation/state/account_profile_state.dart';
import '../../game_core/domain/models/game_difficulty.dart';
import '../../game_core/domain/models/game_scenes.dart';
import '../../progress/domain/models/progress_snapshot.dart';
import '../../progress/domain/repos/progress_repository.dart';
import 'state/level_select_state.dart';
import 'widgets/level_select_difficulty_selector_widget.dart';
import 'widgets/level_select_scene_card_widget.dart';

/// Pre-game scene picker: choose a campaign (terrain + wave count +
/// strategy) before the battle begins.
class LevelSelectPage extends StatefulWidget {
  const LevelSelectPage({super.key});

  @override
  State<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _LevelSelectPageState extends State<LevelSelectPage> {
  final AccountProfileState _accountProfileState = getIt<AccountProfileState>();
  final LevelSelectState _state = LevelSelectState(getIt<ProgressRepository>());
  final ValueNotifier<GameDifficulty> _difficulty = ValueNotifier(
    GameDifficulty.normal,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: AppThemePaddings.h16v24,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                              S.current.levelSelectTitle,
                              style: const TextStyle(
                                color: AppThemeColors.textPrimary,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: -0.2, end: 0),
                        const SizedBox(height: AppThemeSpacing.space6),
                        Text(
                              S.current.levelSelectSubtitle,
                              style: const TextStyle(
                                color: AppThemeColors.textSecondary,
                                fontSize: 16,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 80.ms)
                            .slideY(begin: -0.2, end: 0),
                        const SizedBox(height: AppThemeSpacing.space28),
                        ValueListenableBuilder<ProgressSnapshot?>(
                          valueListenable: _state.progress,
                          builder: (context, progressValue, _) {
                            final progress =
                                progressValue ?? ProgressSnapshot.empty;
                            return ValueListenableBuilder<GameDifficulty>(
                              valueListenable: _difficulty,
                              builder: (context, difficulty, _) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AccountBadge(state: _accountProfileState),
                                    Center(
                                      child:
                                          LevelSelectDifficultySelectorWidget(
                                            value: difficulty,
                                            onChanged: (value) =>
                                                _difficulty.value = value,
                                          ),
                                    ),
                                    const SizedBox(height: AppThemeSpacing.space20),
                                    GridView.count(
                                      shrinkWrap: true,
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: 1.4,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: [
                                        for (final (index, scene)
                                            in GameScenes.all.indexed)
                                          LevelSelectSceneCardWidget(
                                                scene: scene,
                                                progress: progress,
                                                difficulty: difficulty,
                                                onReturn: _state.load,
                                              )
                                              .animate()
                                              .fadeIn(
                                                duration: 380.ms,
                                                delay: (120 + index * 90).ms,
                                              )
                                              .scale(
                                                begin: const Offset(0.92, 0.92),
                                                curve: Curves.easeOutCubic,
                                              ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
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

  @override
  void dispose() {
    _state.dispose();
    _difficulty.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _state.load();
  }
}
