import '../../../core/combat/unit_kind.dart';
import '../../waves/domain/models/wave_definition.dart';
import '../../waves/domain/models/wave_loadout.dart';
import '../../waves/domain/repos/wave_repository.dart';

/// Reasonable pacing defaults for a spawn entry built from a hand-authored
/// [WaveLoadout] count (no interval/startDelay is stored per-unit in the
/// editor, just a raw headcount) - mirrors [WaveRepositoryImpl]'s rough feel
/// per unit kind without copying its escalating-difficulty formula.
const Map<UnitKind, double> _intervalFor = {
  UnitKind.soldier: 0.8,
  UnitKind.heavySoldier: 1.3,
  UnitKind.helicopter: 1.7,
  UnitKind.gunboat: 2.0,
  UnitKind.tank: 2.0,
  UnitKind.attackPlane: 1.9,
  UnitKind.lightVehicle: 1.6,
  UnitKind.aircraft: 1.9,
  UnitKind.artilleryBarrage: 2.6,
  UnitKind.rocketBarrage: 2.4,
  UnitKind.antiAirVehicle: 2.4,
};

/// A [WaveRepository] backed by a map draft's author-controlled
/// [WaveLoadout]s instead of a procedural formula - each configured wave
/// spends exactly the unit budget the author (or the "Randomize" tool) gave
/// it. Any wave number left uncustomized (or with an empty loadout) falls
/// through to [fallback], so an untouched draft still plays exactly like the
/// built-in campaigns.
class DraftWaveRepository implements WaveRepository {
  final List<WaveLoadout> loadouts;
  final WaveRepository fallback;

  @override
  final int totalWaves;

  DraftWaveRepository({
    required this.loadouts,
    required this.fallback,
    required int totalWaves,
  }) : totalWaves = totalWaves.clamp(1, 200);

  @override
  WaveDefinition waveDefinition(int waveNumber) {
    final n = waveNumber.clamp(1, totalWaves);
    WaveLoadout? loadout;
    for (final candidate in loadouts) {
      if (candidate.waveNumber == n) {
        loadout = candidate;
        break;
      }
    }
    if (loadout == null || loadout.unitCounts.isEmpty) {
      return fallback.waveDefinition(n);
    }
    final spawns = <SpawnEntry>[
      for (final entry in loadout.unitCounts.entries)
        if (entry.value > 0)
          SpawnEntry(
            type: UnitKind.values.byName(entry.key),
            count: entry.value,
            interval: _intervalFor[UnitKind.values.byName(entry.key)] ?? 1.0,
          ),
    ];
    return WaveDefinition(waveNumber: n, spawns: spawns);
  }
}
