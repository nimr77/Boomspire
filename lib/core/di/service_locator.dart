import 'package:get_it/get_it.dart';

import '../../features/account/domain/repos/account_repository.dart';
import '../../features/account/impl/local_account_repository_impl.dart';
import '../../features/account/presentation/state/account_profile_state.dart';
import '../../features/ai_director/domain/repos/ai_director_repository.dart';
import '../../features/ai_director/impl/ai_director_repository_impl.dart';
import '../../features/audio/domain/repos/audio_repository.dart';
import '../../features/audio/impl/audio_repository_impl.dart';
import '../../features/game_content/domain/models/game_object_definition.dart';
import '../../features/game_core/domain/repos/game_state_repository.dart';
import '../../features/game_core/impl/game_state_repository_impl.dart';
import '../../features/game_core/presentation/state/game_core_production_state.dart';
import '../../features/map_editor/domain/repos/map_draft_repository.dart';
import '../../features/map_editor/impl/local_map_draft_repository_impl.dart';
import '../../features/progress/domain/repos/progress_repository.dart';
import '../../features/progress/impl/local_progress_repository_impl.dart';
import '../../features/terrain/domain/models/biome.dart';
import '../../features/terrain/domain/repos/terrain_repository.dart';
import '../../features/terrain/impl/terrain_repository_impl.dart';
import '../../features/towers/domain/repos/building_repository.dart';
import '../../features/towers/domain/repos/tower_repository.dart';
import '../../features/towers/impl/building_repository_impl.dart';
import '../../features/towers/impl/tower_repository_impl.dart';
import '../../features/waves/domain/repos/wave_repository.dart';
import '../../features/waves/impl/wave_repository_impl.dart';
import '../combat/mobile_unit_repository.dart';
import '../combat/mobile_unit_repository_impl.dart';
import '../rendering/domain/repos/unit_render_repository.dart';
import '../rendering/impl/composite_unit_render_repository_impl.dart';

/// App-wide service locator - the single composition root for every
/// repository. Call [setupServiceLocator] once, before `runApp`.
final GetIt getIt = GetIt.instance;

/// Registers every repository binding. Idempotent: a second call (e.g. a
/// widget test that pumps the app more than once) is a no-op.
///
/// [gameContentOverrides] is whatever `GameContentSyncService` resolved at
/// boot (empty by default - no sync has happened, e.g. every existing
/// test), layered on top of `TowerRepositoryImpl`/`BuildingRepositoryImpl`/
/// `MobileUnitRepositoryImpl`'s own hardcoded fallback stats.
void setupServiceLocator({
  List<GameObjectDefinition> gameContentOverrides = const [],
}) {
  if (getIt.isRegistered<AccountRepository>()) return;

  // Stateless/shared services - one instance for the whole app lifetime.
  getIt
    ..registerLazySingleton<ProgressRepository>(
      () => LocalProgressRepositoryImpl(),
    )
    ..registerLazySingleton<AccountRepository>(
      () => LocalAccountRepositoryImpl(
        progressRepository: getIt<ProgressRepository>(),
      ),
    )
    ..registerLazySingleton<AccountProfileState>(
      () => AccountProfileState(getIt<AccountRepository>()),
    )
    ..registerLazySingleton<GameCoreProductionState>(
      () => GameCoreProductionState(),
    )
    ..registerLazySingleton<MapDraftRepository>(
      () => LocalMapDraftRepositoryImpl(),
    )
    ..registerLazySingleton<TerrainRepository>(() => TerrainRepositoryImpl())
    ..registerLazySingleton<TowerRepository>(
      () => TowerRepositoryImpl(overrides: gameContentOverrides),
    )
    ..registerLazySingleton<BuildingRepository>(
      () => BuildingRepositoryImpl(overrides: gameContentOverrides),
    )
    ..registerLazySingleton<MobileUnitRepository>(
      () => MobileUnitRepositoryImpl(overrides: gameContentOverrides),
    )
    ..registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl())
    ..registerLazySingleton<UnitRenderRepository>(
      () => CompositeUnitRenderRepositoryImpl(),
    )
    ..registerLazySingleton<AiDirectorRepository>(
      () => AiDirectorRepositoryImpl(),
    )
    // Per-run session state - a fresh instance is required every game.
    ..registerFactory<GameStateRepository>(() => GameStateRepositoryImpl())
    ..registerFactoryParam<WaveRepository, int, Biome>(
      (totalWaves, biome) =>
          WaveRepositoryImpl(totalWaves: totalWaves, biome: biome),
    );
}
