import '../../enemies/domain/models/enemy_type.dart';
import '../domain/models/wave_definition.dart';
import '../domain/repos/wave_repository.dart';

/// Procedurally scales an escalating spawn composition up to whatever
/// [totalWaves] the current scene calls for, instead of a fixed hardcoded
/// round count - so every scene can define its own campaign length.
class WaveRepositoryImpl implements WaveRepository {
  @override
  final int totalWaves;

  WaveRepositoryImpl({required int totalWaves})
    : totalWaves = totalWaves.clamp(3, 30);

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
          type: EnemyType.helicopter,
          count: (1 + (n - 2) * 0.8).round(),
          interval: (1.9 - n * 0.05).clamp(0.9, 1.9),
          startDelay: 3,
        ),
      );
    }

    if (n >= 4) {
      spawns.add(
        SpawnEntry(
          type: EnemyType.tank,
          count: (1 + (n - 4) * 0.5).round(),
          interval: (2.6 - n * 0.05).clamp(1.6, 2.6),
          startDelay: 4,
        ),
      );
    }

    if (n >= 5) {
      spawns.add(
        SpawnEntry(
          type: EnemyType.attackPlane,
          count: (1 + (n - 5) * 0.6).round(),
          interval: (2.2 - n * 0.05).clamp(1.2, 2.2),
          startDelay: 5,
        ),
      );
    }

    return WaveDefinition(waveNumber: n, spawns: spawns);
  }
}
