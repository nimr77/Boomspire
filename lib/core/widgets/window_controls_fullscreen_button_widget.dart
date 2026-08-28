import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../generated/l10n.dart';

/// Fullscreen toggle icon button (desktop only) - tracks the OS window's
/// live fullscreen state so its icon/tooltip stay in sync even if the user
/// toggles fullscreen via a native OS shortcut instead of this button.
class WindowControlsFullscreenButtonWidget extends StatefulWidget {
  const WindowControlsFullscreenButtonWidget({super.key});

  @override
  State<WindowControlsFullscreenButtonWidget> createState() =>
      _WindowControlsFullscreenButtonWidgetState();
}

class _WindowControlsFullscreenButtonWidgetState
    extends State<WindowControlsFullscreenButtonWidget> {
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
