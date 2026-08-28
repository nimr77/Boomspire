import 'package:flutter/material.dart';

import '../../../game_core/presentation/player_palette.dart';

/// A single numbered, colored home-site marker that glows and scales up on
/// hover, and reports taps via [onTap].
class SkirmishPlacementHomeSiteMarkerWidget extends StatelessWidget {
  static const _radius = 18.0;
  static const _hitPadding = 10.0;

  final Offset center;
  final int index;
  final bool selected;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;

  const SkirmishPlacementHomeSiteMarkerWidget({
    super.key,
    required this.center,
    required this.index,
    required this.selected,
    required this.hovered,
    required this.onHoverChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = PlayerPalette.colorFor(index);
    const diameter = _radius * 2;
    const hitSize = diameter + _hitPadding * 2;
    return Positioned(
      left: center.dx - hitSize / 2,
      top: center.dy - hitSize / 2,
      width: hitSize,
      height: hitSize,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => onHoverChanged(true),
        onExit: (_) => onHoverChanged(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: AnimatedScale(
              scale: hovered ? 1.25 : 1.0,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: Colors.white,
                    width: selected ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: hovered ? 0.9 : 0.35),
                      blurRadius: hovered ? 20 : 6,
                      spreadRadius: hovered ? 4 : 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
