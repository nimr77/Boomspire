import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../theme/app_theme/app_theme_colors.dart';
import '../../theme/app_theme/app_theme_paddings.dart';
import 'window_controls_fullscreen_button_widget.dart';

/// Small pill of icon buttons for window-level chrome (fullscreen toggle,
/// and optionally "exit to menu") - meant to float in a screen corner over
/// any background. Fullscreen toggling only applies on desktop platforms;
/// on web/mobile only [onExit] (if provided) is shown.
class WindowControls extends StatelessWidget {
  static bool get _supportsFullscreen =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  final VoidCallback? onExit;

  const WindowControls({super.key, this.onExit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppThemePaddings.h4v4,
      decoration: BoxDecoration(
        color: AppThemeColors.glassPill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_supportsFullscreen) const WindowControlsFullscreenButtonWidget(),
          if (onExit != null)
            IconButton(
              tooltip: S.current.exitToMenuTooltip,
              icon: const Icon(
                Icons.exit_to_app,
                color: AppThemeColors.textMuted,
                size: 20,
              ),
              onPressed: onExit,
            ),
        ],
      ),
    );
  }
}
