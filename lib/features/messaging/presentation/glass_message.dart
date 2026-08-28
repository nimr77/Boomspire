import 'dart:ui';

import 'package:flutter/material.dart';

import 'widgets/messaging_glass_card_widget.dart';

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
              child: MessagingGlassCardWidget(
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
