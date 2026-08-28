import 'package:flutter/material.dart';

import 'game_core_tower_action_animated_label_widget.dart';

/// Small action button in [TowerActionPanel]'s stat row (repair, upgrade,
/// anti-rocket, sell) - dims and disables its tap when unaffordable/locked.
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
    this.color = Colors.lightBlueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xB31A1F26),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(height: 2),
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
