import 'package:flutter/material.dart';

import 'mesh_background.dart';

/// The persistent frame every routed page renders inside of (wired as a
/// `ShellRoute` builder in `core/router/router.dart`) - keeps one
/// [GameMeshBackgroundWidget] instance alive behind [child] across
/// navigation, so it never restarts/re-fades when the route changes, only
/// the page on top of it does.
class AppShellWidget extends StatelessWidget {
  final Widget child;

  const AppShellWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: GameMeshBackgroundWidget()),
        child,
      ],
    );
  }
}
