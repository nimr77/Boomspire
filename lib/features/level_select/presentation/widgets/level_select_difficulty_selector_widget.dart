import 'package:flutter/material.dart';

import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../game_core/domain/models/game_difficulty.dart';
import '../../../game_core/extensions/game_difficulty_extensions.dart';
import 'level_select_difficulty_segment_widget.dart';

/// Segmented easy/normal/hard picker - scales AI aggression and rations the
/// Laser Lance build limit for the run about to start. Styled as a single
/// HUD panel (matching the build menu's tab strip) rather than loose chips.
class LevelSelectDifficultySelectorWidget extends StatelessWidget {
  final GameDifficulty value;
  final ValueChanged<GameDifficulty> onChanged;

  const LevelSelectDifficultySelectorWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppThemePaddings.all4,
      decoration: BoxDecoration(
        color: AppThemeColors.surfacePanel,
        borderRadius: AppThemeBorders.radius10,
        border: Border.all(
          color: AppThemeColors.surfacePanelBorder,
          width: AppThemeBorders.width1_5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final difficulty in GameDifficulty.values)
            LevelSelectDifficultySegmentWidget(
              label: difficulty.label,
              selected: value == difficulty,
              onTap: () => onChanged(difficulty),
            ),
        ],
      ),
    );
  }
}
