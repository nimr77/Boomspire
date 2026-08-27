import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../generated/l10n.dart';

/// Small pill of icon buttons for window-level chrome (fullscreen toggle,
/// and optionally "exit to menu") - meant to float in a screen corner over
/// any background. Fullscreen toggling only applies on desktop platforms;
/// on web/mobile only [onExit] (if provided) is shown.
class WindowControls extends StatelessWidget {
  static bool get _supportsFullscreen =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  final VoidCallback? onExit;

  const WindowControls({super.key, this.onExit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xB31A1F26),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_supportsFullscreen) const _FullscreenButton(),
          if (onExit != null)
            IconButton(
              tooltip: S.current.exitToMenuTooltip,
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: onExit,
            ),
        ],
      ),
    );
  }
}

class _FullscreenButton extends StatefulWidget {
  const _FullscreenButton();

  @override
  State<_FullscreenButton> createState() => _FullscreenButtonState();
}

class _FullscreenButtonState extends State<_FullscreenButton> {
  final ValueNotifier<bool> _isFullscreen = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isFullscreen,
      builder: (context, isFullscreen, _) {
        return IconButton(
          tooltip: isFullscreen
              ? S.current.exitFullscreenTooltip
              : S.current.enterFullscreenTooltip,
          icon: Icon(
            isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            color: Colors.white70,
            size: 20,
          ),
          onPressed: _toggle,
        );
      },
    );
  }

  @override
  void dispose() {
    _isFullscreen.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    windowManager.isFullScreen().then((value) {
      if (mounted) _isFullscreen.value = value;
    });
  }

  Future<void> _toggle() async {
    final next = !_isFullscreen.value;
    await windowManager.setFullScreen(next);
    if (mounted) _isFullscreen.value = next;
  }
}
