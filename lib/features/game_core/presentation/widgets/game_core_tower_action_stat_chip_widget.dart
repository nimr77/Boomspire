import 'package:flutter/material.dart';

/// Small icon+text pill for a passive stat readout - used by the Gold
/// Mine's row and a unit's fire-stats row in `GameCoreEntityPanelWidget`
/// since those are informational, with no action button.
class GameCoreTowerActionStatChipWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const GameCoreTowerActionStatChipWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xB31A1F26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
