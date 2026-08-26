import 'dart:ui';

import 'package:flutter/material.dart';

/// Shows a frosted-glass "messaging" surface: forces focus onto its content
/// by blurring/dimming everything behind it, then presents a rounded,
/// animated glass card - centered as a dialog on wide/desktop layouts, or
/// docked to the bottom as a sheet on narrow/mobile layouts.
Future<T?> showGlassMessage<T>(
  BuildContext context, {
  required WidgetBuilder contentBuilder,
  bool barrierDismissible = true,
}) {
  final isDesktop = MediaQuery.sizeOf(context).width >= 700;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).dialogLabel,
    barrierColor: const Color(0x66050608),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, _, _) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, _) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18 * curved.value,
          sigmaY: 18 * curved.value,
        ),
        child: FadeTransition(
          opacity: curved,
          child: Align(
            alignment: isDesktop ? Alignment.center : Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: isDesktop ? const Offset(0, 0.04) : const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: _GlassCard(
                isDesktop: isDesktop,
                child: Builder(builder: contentBuilder),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _GlassCard extends StatelessWidget {
  final bool isDesktop;
  final Widget child;

  const _GlassCard({required this.isDesktop, required this.child});

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
          padding: EdgeInsets.all(isDesktop ? 24 : 0),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
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
