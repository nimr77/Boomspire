import 'package:flutter/material.dart';

import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';

/// A small icon+text pill used in [HudOverlay]'s left-hand stat column
/// (health/gold/score).
class GameCoreHudStatChipWidget extends StatelessWidget {
  final IconData icon;

  final Color color;
  final String label;
  const GameCoreHudStatChipWidget({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppThemePaddings.h12v4,
      decoration: BoxDecoration(
        color: AppThemeColors.glassPill,
        borderRadius: AppThemeBorders.radius20,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: AppThemeSpacing.space6),
          Text(
            label,
            style: const TextStyle(
              color: AppThemeColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
