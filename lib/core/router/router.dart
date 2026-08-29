import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_shell_widget.dart';
import 'routes.dart';

/// Single app-wide [GoRouter] instance, consumed by `MaterialApp.router`.
/// Every route is nested under one [ShellRoute] so [AppShellWidget]'s mesh
/// background stays mounted/uninterrupted across navigation - only the
/// matched page (transitioning via [_sharedAxisPageBuilder]) changes.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: Routes.mainMenu.route,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShellWidget(child: child),
      routes: [
        for (final r in Routes.values)
          GoRoute(path: r.route, pageBuilder: _sharedAxisPageBuilder(r)),
      ],
    ),
  ],
);

/// Root navigator key - lets code without a [BuildContext] (e.g. the
/// account-prompt bootstrap in `main.dart`) reach the current route's
/// context via `rootNavigatorKey.currentContext`.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Wraps [Routes.build] in a horizontal shared-axis transition
/// (https://pub.dev/packages/animations#shared-axis) instead of go_router's
/// default platform transition.
Page<void> Function(BuildContext, GoRouterState) _sharedAxisPageBuilder(
  Routes route,
) {
  return (context, state) => CustomTransitionPage<void>(
    key: state.pageKey,
    child: route.build(context, state),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: Colors.transparent,
          child: child,
        ),
  );
}
