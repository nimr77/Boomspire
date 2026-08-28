import 'package:flutter/material.dart';

import '../../theme/app_theme/app_theme_colors.dart';
import '../../theme/app_theme/app_theme_paddings.dart';
import '../../theme/app_theme/app_theme_spacing.dart';

/// Icon + title + subtitle content for a big menu option card (main menu,
/// mode select) - a soft gradient background tinted by [accentColor] with a
/// large icon, bold title, and a muted subtitle line.
class MenuOptionContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;

  const MenuOptionContent({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.16),
            AppThemeColors.gradientPanelEnd,
          ],
        ),
      ),
      padding: AppThemePaddings.h24v22,
      child: Row(
        children: [
          Container(
            padding: AppThemePaddings.all14,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 30),
          ),
          const SizedBox(width: AppThemeSpacing.space18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: AppThemeSpacing.space4,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppThemeColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppThemeColors.textDim,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: accentColor.withValues(alpha: 0.8)),
        ],
      ),
    );
  }
}
