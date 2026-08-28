import 'package:flutter/material.dart';

/// Fades/slides a label in whenever its text changes - used so cost/state
/// text in the entity panel (gold costs, "MAX", "Active"...) doesn't just
/// snap when the underlying tower/unit stat changes.
class GameCoreTowerActionAnimatedLabelWidget extends StatelessWidget {
  final String label;
  final TextStyle style;

  const GameCoreTowerActionAnimatedLabelWidget({
    super.key,
    required this.label,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Text(label, key: ValueKey(label), style: style),
    );
  }
}
