import 'package:flutter/material.dart';

/// Small pill toggle used to switch between the Towers/Buildings tabs.
class GameCoreBuildMenuTabWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const GameCoreBuildMenuTabWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.14) : null,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? Colors.white70 : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
