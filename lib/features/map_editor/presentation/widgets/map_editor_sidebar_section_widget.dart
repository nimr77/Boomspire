import 'package:flutter/material.dart';

import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';

/// Collapsible card used to group one property-panel section (Brush, Map,
/// Waves, Environment) in the map editor's side panel - gives each section
/// a distinct bordered surface with an icon + title header instead of a
/// bare caps-label separated only by a thin divider, and lets a long
/// section (e.g. Waves' per-unit-kind rows) be collapsed out of the way.
class MapEditorSidebarSectionWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const MapEditorSidebarSectionWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.initiallyExpanded = true,
  });

  @override
  State<MapEditorSidebarSectionWidget> createState() =>
      _MapEditorSidebarSectionWidgetState();
}

class _MapEditorSidebarSectionWidgetState
    extends State<MapEditorSidebarSectionWidget> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppThemeSpacing.space16),
      decoration: BoxDecoration(
        color: AppThemeColors.surfacePanel,
        borderRadius: AppThemeBorders.radius14,
        border: Border.all(
          color: AppThemeColors.borderSubtle,
          width: AppThemeBorders.width1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: AppThemeBorders.radius14,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: AppThemePaddings.all12,
              child: Row(
                children: [
                  Icon(widget.icon, color: AppThemeColors.accentCyan, size: 18),
                  SizedBox(width: AppThemeSpacing.space8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppThemeColors.accentCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.expand_more,
                      color: AppThemeColors.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppThemeSpacing.space12,
                      0,
                      AppThemeSpacing.space12,
                      AppThemeSpacing.space12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: widget.children,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
