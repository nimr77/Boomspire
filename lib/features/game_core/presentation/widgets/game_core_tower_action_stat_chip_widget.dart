import 'package:flutter/material.dart';

import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';

/// Small icon+text pill for a passive stat readout - used by the Gold
/// Mine's row and a unit's fire-stats row in `GameCoreEntityPanelWidget`
/// since those are informational, with no action button.
class GameCoreTowerActionStatChipWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const GameCoreTowerActionStatChipWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppThemePaddings.h8v5,
      decoration: BoxDecoration(
        color: AppThemeColors.glassPill,
        borderRadius: AppThemeBorders.radius8,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: AppThemeSpacing.space4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
