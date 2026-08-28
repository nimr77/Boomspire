import 'package:flutter/material.dart';

/// Single easy/normal/hard option inside [LevelSelectDifficultySelectorWidget]
/// - a HUD-styled segment (matches the build menu's tab strip) rather than
/// a stock Material chip.
class LevelSelectDifficultySegmentWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const LevelSelectDifficultySegmentWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Colors.cyanAccent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.cyanAccent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.cyanAccent : Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
