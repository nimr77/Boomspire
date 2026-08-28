import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../theme/app_theme/app_theme_paddings.dart';

/// The rounded, frosted card body used by [showGlassMessage] - centered as
/// a dialog on wide/desktop layouts, or docked to the bottom as a sheet on
/// narrow/mobile layouts.
class MessagingGlassCardWidget extends StatelessWidget {
  final bool isDesktop;
  final Widget child;

  const MessagingGlassCardWidget({
    super.key,
    required this.isDesktop,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final radius = isDesktop
        ? const BorderRadius.all(Radius.circular(24))
        : const BorderRadius.vertical(top: Radius.circular(28));
    return SafeArea(
      top: isDesktop,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 440 : double.infinity,
        ),
        child: Padding(
          padding: isDesktop ? AppThemePaddings.all24 : EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                width: double.infinity,
                padding: AppThemePaddings.all28,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.16),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Material(type: MaterialType.transparency, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
