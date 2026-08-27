import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/game_core/domain/models/game_difficulty.dart';
import '../../features/game_core/domain/models/game_scene.dart';
import '../../features/level_select/presentation/level_select_page.dart';
import '../../features/level_select/presentation/main_menu_page.dart';
import '../../features/level_select/presentation/single_player_mode_select_page.dart';
import '../../features/level_select/presentation/skirmish_level_select_page.dart';
import '../../features/map_editor/domain/models/map_draft.dart';
import '../../features/map_editor/presentation/map_drafts_list_page.dart';
import '../../features/terrain/domain/repos/terrain_repository.dart';
import '../../features/waves/domain/repos/wave_repository.dart';
import 'route_pages.dart';

/// Every screen in the app: its path and its widget builder live together
/// here, driving [appRouter] - add a new screen by adding one case here.
enum Routes {
  mainMenu,
  singlePlayerModeSelect,
  towerDefenseLevelSelect,
  skirmishLevelSelect,
  skirmishPlacement,
  game,
  mapEditorList;

  static const Map<Routes, String> _routes = {
    Routes.mainMenu: '/',
    Routes.singlePlayerModeSelect: '/single-player',
    Routes.towerDefenseLevelSelect: '/single-player/tower-defense',
    Routes.skirmishLevelSelect: '/single-player/skirmish',
    Routes.skirmishPlacement: '/single-player/skirmish/placement',
    Routes.game: '/game',
    Routes.mapEditorList: '/map-editor',
  };

  static Map<Routes, Widget Function(BuildContext, GoRouterState)>
  get _builder => {
    Routes.mainMenu: (_, _) => const MainMenuPage(),
    Routes.singlePlayerModeSelect: (_, _) =>
        const SinglePlayerModeSelectPage(),
    Routes.towerDefenseLevelSelect: (_, _) => const LevelSelectPage(),
    Routes.skirmishLevelSelect: (_, _) => const SkirmishLevelSelectPage(),
    Routes.skirmishPlacement: (_, state) =>
        SkirmishPlacementRoutePage(state: state),
    Routes.game: (_, state) => GameRoutePage(state: state),
    Routes.mapEditorList: (_, _) => const MapDraftsListPage(),
  };

  /// The path this route is registered under and navigated to, e.g.
  /// `context.push(Routes.game.route, extra: GameRouteArgs(...))`.
  String get route => _routes[this]!;

  /// Builds this route's screen - used by [appRouter] to wire up each
  /// [GoRoute].
  Widget build(BuildContext context, GoRouterState state) =>
      _builder[this]!(context, state);
}

/// `extra` payload for [Routes.game] - go_router paths are plain strings, so
/// non-serializable objects (repository overrides used by the map editor's
/// test-play) are carried this way instead of as query params.
class GameRouteArgs {
  final GameScene scene;
  final GameDifficulty difficulty;
  final TerrainRepository? terrainRepository;
  final WaveRepository? waveRepository;

  const GameRouteArgs({
    required this.scene,
    this.difficulty = GameDifficulty.normal,
    this.terrainRepository,
    this.waveRepository,
  });
}

/// `extra` payload for [Routes.skirmishPlacement] - provide exactly one of
/// [scene] (built-in skirmish scene) or [draft] (hand-authored map),
/// matching [SkirmishPlacementPage]'s own constructor contract.
class SkirmishPlacementArgs {
  final GameScene? scene;
  final MapDraft? draft;

  const SkirmishPlacementArgs({this.scene, this.draft})
    : assert(
        (scene == null) != (draft == null),
        'Provide exactly one of scene or draft',
      );
}
