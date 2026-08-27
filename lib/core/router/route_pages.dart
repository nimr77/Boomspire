import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/game_core/presentation/game_page.dart';
import '../../features/level_select/presentation/skirmish_placement_page.dart';
import 'routes.dart';

final _gameArgs = _RouteArgCache<GameRouteArgs>();

final _skirmishPlacementArgs = _RouteArgCache<SkirmishPlacementArgs>();

/// Router-builder wrapper for [Routes.game] - stashes the pushed
/// [GameRouteArgs] in [_gameArgs] instead of casting `state.extra` inline
/// in [Routes]'s builder map, and evicts it once this page is disposed.
class GameRoutePage extends StatefulWidget {
  final GoRouterState state;

  const GameRoutePage({super.key, required this.state});

  @override
  State<GameRoutePage> createState() => _GameRoutePageState();
}

/// Router-builder wrapper for [Routes.skirmishPlacement] - same
/// stash-on-mount/evict-on-dispose lifecycle as [GameRoutePage].
class SkirmishPlacementRoutePage extends StatefulWidget {
  final GoRouterState state;

  const SkirmishPlacementRoutePage({super.key, required this.state});

  @override
  State<SkirmishPlacementRoutePage> createState() =>
      _SkirmishPlacementRoutePageState();
}

class _GameRoutePageState extends State<GameRoutePage> {
  @override
  Widget build(BuildContext context) {
    final args = _gameArgs.value;
    return GamePage(
      scene: args.scene,
      difficulty: args.difficulty,
      terrainRepository: args.terrainRepository,
      waveRepository: args.waveRepository,
    );
  }

  @override
  void dispose() {
    _gameArgs.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _gameArgs.set(widget.state.extra! as GameRouteArgs);
  }
}

/// Single-slot holder for one route's non-serializable `extra` payload -
/// the owning wrapper widget writes it on mount and must clear it on
/// dispose so pushed objects (repositories, scenes) don't stay referenced
/// after the page closes.
class _RouteArgCache<T> {
  T? _value;

  T get value => _value!;
  void clear() => _value = null;
  void set(T value) => _value = value;
}

class _SkirmishPlacementRoutePageState
    extends State<SkirmishPlacementRoutePage> {
  @override
  Widget build(BuildContext context) {
    final args = _skirmishPlacementArgs.value;
    return SkirmishPlacementPage(scene: args.scene, draft: args.draft);
  }

  @override
  void dispose() {
    _skirmishPlacementArgs.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _skirmishPlacementArgs.set(widget.state.extra! as SkirmishPlacementArgs);
  }
}
