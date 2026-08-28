import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../theme/app_theme/app_theme_borders.dart';
import '../../../../theme/app_theme/app_theme_colors.dart';
import '../../../../theme/app_theme/app_theme_paddings.dart';
import '../../../game_core/presentation/player_palette.dart';

/// A "1 · You"/"2 · AI" chip below the placement surface identifying each
/// seat's color and current owner, glowing on hover.
class SkirmishPlacementSeatChipWidget extends StatefulWidget {
  final int index;
  final bool isYou;

  const SkirmishPlacementSeatChipWidget({
    super.key,
    required this.index,
    required this.isYou,
  });

  @override
  State<SkirmishPlacementSeatChipWidget> createState() =>
      _SkirmishPlacementSeatChipWidgetState();
}

class _SkirmishPlacementSeatChipWidgetState
    extends State<SkirmishPlacementSeatChipWidget> {
  final ValueNotifier<bool> _hovered = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final color = PlayerPalette.colorFor(widget.index);
    return MouseRegion(
      onEnter: (_) => _hovered.value = true,
      onExit: (_) => _hovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _hovered,
        builder: (context, hovered, _) {
          return AnimatedScale(
            scale: hovered ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: AppThemePaddings.h12v6,
              decoration: BoxDecoration(
                color: color.withValues(alpha: widget.isYou ? 0.35 : 0.12),
                borderRadius: AppThemeBorders.radius20,
                border: Border.all(
                  color: color,
                  width: widget.isYou
                      ? AppThemeBorders.width2
                      : AppThemeBorders.width1,
                ),
                boxShadow: hovered
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.7),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ]
                    : const [],
              ),
              child: Text(
                '${widget.index + 1} · ${widget.isYou ? S.current.skirmishPlacementYou : S.current.skirmishPlacementAi}',
                style: TextStyle(
                  color: AppThemeColors.textPrimary,
                  fontSize: 12,
                  fontWeight: widget.isYou
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _hovered.dispose();
    super.dispose();
  }
}
