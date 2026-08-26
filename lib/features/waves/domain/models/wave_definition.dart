import '../../../enemies/domain/models/enemy_type.dart';

/// One group of enemies spawned within a wave.
class SpawnEntry {
  final EnemyType type;

  final int count;

  /// Seconds between each spawn within this entry.
  final double interval;

  /// Seconds after wave start before this entry begins spawning.
  final double startDelay;

  const SpawnEntry({
    required this.type,
    required this.count,
    required this.interval,
    this.startDelay = 0,
  });
}

/// Full definition of a single wave/round.
class WaveDefinition {
  final int waveNumber;

  final List<SpawnEntry> spawns;
  const WaveDefinition({required this.waveNumber, required this.spawns});

  int get totalEnemies => spawns.fold(0, (sum, s) => sum + s.count);
}
