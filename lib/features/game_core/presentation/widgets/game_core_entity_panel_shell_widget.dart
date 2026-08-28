import 'dart:ui';

import 'package:flutter/material.dart';

import 'game_core_tower_action_animated_label_widget.dart';

/// The ONE frosted-glass card shell every selection/inspection panel is
/// built from - a building, a tower, or a unit all render through this same
/// container (icon + title + optional subtitle + optional owner chip +
/// optional close button up top, arbitrary type-specific content below).
/// Docked at the left edge of the arena by [GameCoreEntityPanelWidget].
class GameCoreEntityPanelShellWidget extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String? subtitle;
  final String? ownerLabel;
  final Color? ownerColor;
  final VoidCallback? onClose;
  final Widget? child;

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
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                if (ownerLabel != null) ...[
                  const SizedBox(height: 6),
                  _buildOwnerChip(),
                ],
                if (child != null) ...[const SizedBox(height: 10), child!],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accentColor, size: 18),
        const SizedBox(width: 8),
        Flexible(
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
        ),
        if (onClose != null) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(12),
            child: const Icon(Icons.close, color: Colors.white54, size: 18),
          ),
        ],
      ],
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
