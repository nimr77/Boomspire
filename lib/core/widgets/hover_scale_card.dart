import 'package:flutter/material.dart';

/// A tappable card that scales up and brightens its border on mouse hover
/// (desktop/web) and on press (touch) - used by the main menu / mode-select
/// screens so each big option feels alive without needing a full custom
/// animation controller per card.
class HoverScaleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color accentColor;
  final BorderRadius borderRadius;

  const HoverScaleCard({
    super.key,
    required this.child,
    required this.onTap,
    this.accentColor = Colors.cyanAccent,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  State<HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<HoverScaleCard> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovering || _pressed;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: active ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              border: Border.all(
                color: active
                    ? widget.accentColor
                    : widget.accentColor.withValues(alpha: 0.25),
                width: active ? 2 : 1.5,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 1,
                      ),
                    ]
                  : const [],
            ),
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
