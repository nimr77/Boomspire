import 'package:flutter/material.dart';

import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';
import 'game_core_tower_action_animated_label_widget.dart';

/// Small action button in `GameCoreEntityPanelWidget`'s tower stat row
/// (repair, upgrade, anti-rocket, sell) - dims and disables its tap when
/// unaffordable/locked.
class GameCoreTowerActionButtonWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const GameCoreTowerActionButtonWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.color = AppThemeColors.accentLightBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: AppThemeBorders.radius8,
        child: Container(
          padding: AppThemePaddings.h10v6,
          decoration: BoxDecoration(
            color: AppThemeColors.glassPill,
            borderRadius: AppThemeBorders.radius8,
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(height: AppThemeSpacing.space2),
              GameCoreTowerActionAnimatedLabelWidget(
                label: label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
