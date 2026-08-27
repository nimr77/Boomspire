import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

/// Single app-wide [GoRouter] instance, consumed by `MaterialApp.router`.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: Routes.mainMenu.route,
  routes: [
    for (final r in Routes.values) GoRoute(path: r.route, builder: r.build),
  ],
);

/// Root navigator key - lets code without a [BuildContext] (e.g. the
/// account-prompt bootstrap in `main.dart`) reach the current route's
/// context via `rootNavigatorKey.currentContext`.
final rootNavigatorKey = GlobalKey<NavigatorState>();
