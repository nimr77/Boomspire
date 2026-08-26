import '../../../enemies/domain/models/enemy_type.dart';

/// One group of enemies spawned within a wave.
class SpawnEntry {
  const SpawnEntry({
    required this.type,
    required this.count,
    required this.interval,
    this.startDelay = 0,
  });

  final EnemyType type;
  final int count;

  /// Seconds between each spawn within this entry.
  final double interval;

  /// Seconds after wave start before this entry begins spawning.
  final double startDelay;
}

/// Full definition of a single wave/round.
class WaveDefinition {
  const WaveDefinition({required this.waveNumber, required this.spawns});

  final int waveNumber;
  final List<SpawnEntry> spawns;

  int get totalEnemies => spawns.fold(0, (sum, s) => sum + s.count);
}
