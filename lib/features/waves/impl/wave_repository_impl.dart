import '../../enemies/domain/models/enemy_type.dart';
import '../domain/models/wave_definition.dart';
import '../domain/repos/wave_repository.dart';

/// Procedurally scales an escalating spawn composition up to whatever
/// [totalWaves] the current scene calls for, instead of a fixed hardcoded
/// round count - so every scene can define its own campaign length.
class WaveRepositoryImpl implements WaveRepository {
  WaveRepositoryImpl({required int totalWaves})
    : totalWaves = totalWaves.clamp(3, 30);

  @override
  final int totalWaves;

  @override
  WaveDefinition waveDefinition(int waveNumber) {
    final n = waveNumber.clamp(1, totalWaves);
    final spawns = <SpawnEntry>[
      SpawnEntry(
        type: EnemyType.soldier,
        count: (5 + n * 1.6).round(),
        interval: (0.95 - n * 0.05).clamp(0.3, 0.95),
      ),
    ];

    if (n >= 3) {
      spawns.add(
        SpawnEntry(
          type: EnemyType.heavySoldier,
          count: (1 + (n - 2) * 0.9).round(),
          interval: (1.5 - n * 0.05).clamp(0.7, 1.5),
          startDelay: 2,
        ),
      );
      spawns.add(
        SpawnEntry(
          type: EnemyType.air,
          count: (1 + (n - 2) * 0.8).round(),
          interval: (1.9 - n * 0.05).clamp(0.9, 1.9),
          startDelay: 3,
        ),
      );
    }

    return WaveDefinition(waveNumber: n, spawns: spawns);
  }
}
