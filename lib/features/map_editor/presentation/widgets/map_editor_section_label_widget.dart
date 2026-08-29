import 'package:flutter/material.dart';

import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';

/// Small cyan caps-lock-styled label used to separate side-panel sections
/// (Brush, Map, Waves, Environment) in the map editor.
class MapEditorSectionLabelWidget extends StatelessWidget {
  final String text;

  const MapEditorSectionLabelWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppThemePaddings.bottom8,
      child: Text(
        text,
        style: const TextStyle(
          color: AppThemeColors.accentCyan,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
