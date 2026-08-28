import 'dart:ui';

import 'package:flutter/material.dart';

import 'game_core_tower_action_animated_label_widget.dart';

/// The ONE frosted-glass card shell every selection/inspection panel is
/// built from - a building, a tower, or a unit all render through this same
/// container (icon + title/subtitle + optional owner chip on the left,
/// arbitrary type-specific content laid out beside it, not below - kept to
/// one compact row so it fits the bottom command bar). Docked next to the
/// minimap by [GameCoreEntityPanelWidget].
class GameCoreEntityPanelShellWidget extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String? subtitle;
  final String? ownerLabel;
  final Color? ownerColor;
  final VoidCallback? onClose;
  final Widget? child;
  final Widget? trailing;

  const GameCoreEntityPanelShellWidget({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.title,
    this.subtitle,
    this.ownerLabel,
    this.ownerColor,
    this.onClose,
    this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accentColor.withValues(alpha: 0.55)),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    if (ownerLabel != null) ...[
                      const SizedBox(width: 10),
                      _buildOwnerChip(),
                    ],
                    if (trailing != null) ...[
                      const SizedBox(width: 10),
                      trailing!,
                    ],
                  ],
                ),
                if (child != null) ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: child!,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            GameCoreTowerActionAnimatedLabelWidget(
              label: subtitle!,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildOwnerChip() {
    final color = ownerColor ?? Colors.white54;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(
        ownerLabel!,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
