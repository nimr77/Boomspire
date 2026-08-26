import '../../enemies/domain/models/enemy_type.dart';
import '../domain/models/wave_definition.dart';
import '../domain/repos/wave_repository.dart';

/// Six escalating rounds - the run ends (victory) once wave 6 is cleared.
class WaveRepositoryImpl implements WaveRepository {
  @override
  int get totalWaves => 6;

  @override
  WaveDefinition waveDefinition(int waveNumber) {
    switch (waveNumber) {
      case 1:
        return const WaveDefinition(
          waveNumber: 1,
          spawns: [
            SpawnEntry(type: EnemyType.soldier, count: 6, interval: 0.9),
          ],
        );
      case 2:
        return const WaveDefinition(
          waveNumber: 2,
          spawns: [
            SpawnEntry(type: EnemyType.soldier, count: 9, interval: 0.7),
          ],
        );
      case 3:
        return const WaveDefinition(
          waveNumber: 3,
          spawns: [
            SpawnEntry(type: EnemyType.soldier, count: 8, interval: 0.7),
            SpawnEntry(
              type: EnemyType.heavySoldier,
              count: 2,
              interval: 1.4,
              startDelay: 2,
            ),
            SpawnEntry(
              type: EnemyType.air,
              count: 2,
              interval: 1.8,
              startDelay: 3,
            ),
          ],
        );
      case 4:
        return const WaveDefinition(
          waveNumber: 4,
          spawns: [
            SpawnEntry(type: EnemyType.soldier, count: 10, interval: 0.55),
            SpawnEntry(
              type: EnemyType.heavySoldier,
              count: 4,
              interval: 1.2,
              startDelay: 1.5,
            ),
            SpawnEntry(
              type: EnemyType.air,
              count: 3,
              interval: 1.5,
              startDelay: 2,
            ),
          ],
        );
      case 5:
        return const WaveDefinition(
          waveNumber: 5,
          spawns: [
            SpawnEntry(type: EnemyType.soldier, count: 12, interval: 0.5),
            SpawnEntry(
              type: EnemyType.heavySoldier,
              count: 5,
              interval: 1.0,
              startDelay: 1,
            ),
            SpawnEntry(
              type: EnemyType.air,
              count: 4,
              interval: 1.3,
              startDelay: 1.5,
            ),
          ],
        );
      case 6:
        return const WaveDefinition(
          waveNumber: 6,
          spawns: [
            SpawnEntry(type: EnemyType.soldier, count: 14, interval: 0.4),
            SpawnEntry(
              type: EnemyType.heavySoldier,
              count: 8,
              interval: 0.8,
              startDelay: 1,
            ),
            SpawnEntry(
              type: EnemyType.air,
              count: 6,
              interval: 1.0,
              startDelay: 1,
            ),
          ],
        );
      default:
        throw ArgumentError('No wave defined for $waveNumber');
    }
  }
}
