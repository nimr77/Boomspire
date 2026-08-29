import 'package:flutter/material.dart';

import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';

/// Single easy/normal/hard option inside [LevelSelectDifficultySelectorWidget]
/// - a HUD-styled segment (matches the build menu's tab strip) rather than
/// a stock Material chip.
class LevelSelectDifficultySegmentWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const LevelSelectDifficultySegmentWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppThemeBorders.radius8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        padding: AppThemePaddings.h22v10,
        decoration: BoxDecoration(
          color: selected
              ? AppThemeColors.accentCyan.withValues(alpha: 0.15)
              : AppThemeColors.transparent,
          borderRadius: AppThemeBorders.radius8,
          border: Border.all(
            color: selected
                ? AppThemeColors.accentCyan
                : AppThemeColors.transparent,
            width: AppThemeBorders.width1_5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppThemeColors.accentCyan
                : AppThemeColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
