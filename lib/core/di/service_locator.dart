import 'package:get_it/get_it.dart';

import '../../features/account/domain/repos/account_repository.dart';
import '../../features/account/impl/local_account_repository_impl.dart';
import '../../features/ai_director/domain/repos/ai_director_repository.dart';
import '../../features/ai_director/impl/ai_director_repository_impl.dart';
import '../../features/audio/domain/repos/audio_repository.dart';
import '../../features/audio/impl/audio_repository_impl.dart';
import '../../features/game_core/domain/repos/game_state_repository.dart';
import '../../features/game_core/impl/game_state_repository_impl.dart';
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

/// App-wide service locator - the single composition root for every
/// repository. Call [setupServiceLocator] once, before `runApp`.
final GetIt getIt = GetIt.instance;

/// Registers every repository binding. Idempotent: a second call (e.g. a
/// widget test that pumps the app more than once) is a no-op.
void setupServiceLocator() {
  if (getIt.isRegistered<AccountRepository>()) return;

  // Stateless/shared services - one instance for the whole app lifetime.
  getIt
    ..registerLazySingleton<AccountRepository>(
      () => LocalAccountRepositoryImpl(),
    )
    ..registerLazySingleton<ProgressRepository>(
      () => LocalProgressRepositoryImpl(),
    )
    ..registerLazySingleton<TerrainRepository>(() => TerrainRepositoryImpl())
    ..registerLazySingleton<TowerRepository>(() => TowerRepositoryImpl())
    ..registerLazySingleton<BuildingRepository>(() => BuildingRepositoryImpl())
    ..registerLazySingleton<MobileUnitRepository>(
      () => MobileUnitRepositoryImpl(),
    )
    ..registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl())
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
