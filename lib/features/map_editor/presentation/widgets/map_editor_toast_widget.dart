import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';

/// Frosted, auto-dismissing confirmation toast - the non-modal counterpart
/// to the game's `showGlassMessage` sheet, used for brief editor feedback
/// (saved, playtest notes) that shouldn't block interaction.
class MapEditorToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback onDismissed;

  const MapEditorToastWidget({
    super.key,
    required this.message,
    required this.icon,
    required this.onDismissed,
  });

  @override
  State<MapEditorToastWidget> createState() => _MapEditorToastWidgetState();
}

class _MapEditorToastWidgetState extends State<MapEditorToastWidget>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 180),
  );
  Timer? _dismissTimer;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return Positioned(
      left: 0,
      right: 0,
      bottom: 32,
      child: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(curved),
              child: ClipRRect(
                borderRadius: AppThemeBorders.radius16,
                child: Material(
                  color: AppThemeColors.transparent,
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: AppThemePaddings.h20v14,
                      decoration: BoxDecoration(
                        borderRadius: AppThemeBorders.radius16,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.14),
                            Colors.white.withValues(alpha: 0.04),
                          ],
                        ),
                        border: Border.all(
                          color: AppThemeColors.accentCyan.withValues(
                            alpha: 0.4,
                          ),
                          width: AppThemeBorders.width1_2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.icon,
                            color: AppThemeColors.accentCyan,
                            size: 18,
                          ),
                          SizedBox(width: AppThemeSpacing.space10),
                          Text(
                            widget.message,
                            style: const TextStyle(
                              color: AppThemeColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _dismissTimer = Timer(const Duration(milliseconds: 2200), _dismiss);
  }

  Future<void> _dismiss() async {
    _dismissTimer?.cancel();
    await _controller.reverse();
    widget.onDismissed();
  }
}
