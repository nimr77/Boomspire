import 'package:flutter/material.dart';

import '../../../../theme/app_theme/app_theme_colors.dart';
import '../../../../theme/app_theme/app_theme_paddings.dart';
import '../../../../theme/app_theme/app_theme_spacing.dart';

/// HUD-panel-styled action button for the editor's AppBar (Save/Play) -
/// matches the translucent bordered look used by in-game action buttons
/// rather than a stock Material [FilledButton].
class MapEditorAppBarButtonWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback? onPressed;

  const MapEditorAppBarButtonWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final tint = disabled ? color.withValues(alpha: 0.4) : color;
    return Padding(
      padding: AppThemePaddings.h4v12,
      child: Material(
        color: AppThemeColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            padding: AppThemePaddings.h14v8,
            decoration: BoxDecoration(
              color: AppThemeColors.glassPill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: tint.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tint,
                    ),
                  )
                else
                  Icon(icon, color: tint, size: 16),
                SizedBox(width: AppThemeSpacing.space8),
                Text(
                  label,
                  style: TextStyle(
                    color: tint,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
