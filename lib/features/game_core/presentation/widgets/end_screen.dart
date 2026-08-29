import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';

/// Shared full-screen result panel used by both the victory and defeat
/// overlays.
class EndScreen extends StatelessWidget {
  final String title;

  final String subtitle;
  final Color accentColor;
  final VoidCallback onRestart;
  final VoidCallback? onChangeMap;
  const EndScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onRestart,
    this.onChangeMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeColors.scrimBackground,
      alignment: Alignment.center,
      child:
          Container(
                padding: AppThemePaddings.h40v32,
                decoration: BoxDecoration(
                  color: AppThemeColors.surfacePanel,
                  borderRadius: AppThemeBorders.radius16,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.6),
                    width: AppThemeBorders.width2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.35),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: AppThemeSpacing.space12),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppThemeColors.textMuted,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: AppThemeSpacing.space28),
                    ElevatedButton(
                      onPressed: onRestart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: AppThemeColors.textOnAccent,
                        padding: AppThemePaddings.h28v14,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppThemeBorders.radius10,
                        ),
                      ),
                      child: Text(
                        S.current.playAgain,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    if (onChangeMap != null) ...[
                      SizedBox(height: AppThemeSpacing.space10),
                      TextButton(
                        onPressed: onChangeMap,
                        child: Text(
                          S.current.changeMap,
                          style: const TextStyle(
                            color: AppThemeColors.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 320.ms)
              .scale(
                begin: const Offset(0.85, 0.85),
                curve: Curves.easeOutBack,
              ),
    );
  }
}
