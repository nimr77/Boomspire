import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme/app_theme_borders.dart';
import '../../theme/app_theme/app_theme_colors.dart';

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
    this.accentColor = AppThemeColors.accentCyan,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  State<HoverScaleCard> createState() => _HoverScaleCardState();
}

/// Private hover/press state for [HoverScaleCard]: a page/widget-local
/// holder (not shared) exposing read-only [ValueListenable]s so the card
/// never needs `setState`.
class _HoverPressState {
  final ValueNotifier<bool> _hovering = ValueNotifier(false);
  final ValueNotifier<bool> _pressed = ValueNotifier(false);

  ValueListenable<bool> get hovering => _hovering;
  Listenable get listenable => Listenable.merge([_hovering, _pressed]);
  ValueListenable<bool> get pressed => _pressed;

  void dispose() {
    _hovering.dispose();
    _pressed.dispose();
  }

  void setHovering(bool value) => _hovering.value = value;

  void setPressed(bool value) => _pressed.value = value;
}

class _HoverScaleCardState extends State<HoverScaleCard> {
  final _HoverPressState _state = _HoverPressState();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state.listenable,
      builder: (context, _) {
        final active = _state.hovering.value || _state.pressed.value;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _state.setHovering(true),
          onExit: (_) => _state.setHovering(false),
          child: GestureDetector(
            onTapDown: (_) => _state.setPressed(true),
            onTapCancel: () => _state.setPressed(false),
            onTapUp: (_) => _state.setPressed(false),
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
                    width: active ? AppThemeBorders.width2 : AppThemeBorders.width1_5,
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
      },
    );
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }
}
