import 'package:flutter/material.dart';

import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';

/// Small pill toggle used to switch between the Towers/Buildings tabs.
class GameCoreBuildMenuTabWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const GameCoreBuildMenuTabWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppThemeBorders.radius6,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: AppThemePaddings.h10v5,
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.14) : null,
          borderRadius: AppThemeBorders.radius6,
          border: Border.all(
            color: selected
                ? AppThemeColors.textMuted
                : AppThemeColors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppThemeColors.textPrimary
                : AppThemeColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
