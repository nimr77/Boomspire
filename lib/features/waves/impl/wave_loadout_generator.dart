import 'dart:math';

import '../../../core/combat/unit_kind.dart';
import '../domain/models/wave_loadout.dart';

/// Bulk-authors random per-wave unit budgets for the map editor's "Randomize
/// N waves" action - lets an author generate e.g. 100 waves at once and then
/// hand-edit whichever ones they care about afterward.
class WaveLoadoutGenerator {
  /// Roughly how much each unit "costs" out of a wave's escalating budget -
  /// mirrors [WaveRepositoryImpl]'s intuition that cheap infantry show up
  /// first and heavier/air units only start appearing on later waves.
  static const Map<UnitKind, int> _weight = {
    UnitKind.soldier: 1,
    UnitKind.heavySoldier: 2,
    UnitKind.helicopter: 2,
    UnitKind.gunboat: 2,
    UnitKind.tank: 3,
    UnitKind.attackPlane: 3,
    UnitKind.lightVehicle: 2,
    UnitKind.aircraft: 3,
    UnitKind.artilleryBarrage: 4,
    UnitKind.rocketBarrage: 4,
    UnitKind.antiAirVehicle: 3,
  };

  /// The earliest wave number each unit kind is allowed to appear in when
  /// randomizing - keeps early waves from randomly rolling end-game units.
  static const Map<UnitKind, int> _minWave = {
    UnitKind.soldier: 1,
    UnitKind.heavySoldier: 2,
    UnitKind.helicopter: 2,
    UnitKind.gunboat: 2,
    UnitKind.tank: 3,
    UnitKind.attackPlane: 4,
    UnitKind.lightVehicle: 3,
    UnitKind.aircraft: 4,
    UnitKind.artilleryBarrage: 6,
    UnitKind.rocketBarrage: 7,
    UnitKind.antiAirVehicle: 6,
  };

  /// Generates one [WaveLoadout] per wave number from 1..[waveCount], each
  /// with a random mix of unit kinds unlocked for that wave, scaled so the
  /// total budget spent grows with the wave number.
  static List<WaveLoadout> randomize(int waveCount, {Random? random}) {
    final rng = random ?? Random();
    return [
      for (var waveNumber = 1; waveNumber <= waveCount; waveNumber++)
        randomizeWave(waveNumber, random: rng),
    ];
  }

  /// Generates a single random [WaveLoadout] for [waveNumber] - used both by
  /// [randomize] and by the editor's per-wave "Randomize" action.
  static WaveLoadout randomizeWave(int waveNumber, {Random? random}) {
    final rng = random ?? Random();
    final available = _minWave.entries
        .where((e) => waveNumber >= e.value)
        .map((e) => e.key)
        .toList();
    var budget = 6 + (waveNumber * 2.2).round();
    final counts = <String, int>{};
    // Always seed some cheap infantry so a wave is never empty.
    while (budget > 0 && available.isNotEmpty) {
      final kind = available[rng.nextInt(available.length)];
      final cost = _weight[kind] ?? 1;
      if (cost > budget && counts.isNotEmpty) break;
      counts[kind.name] = (counts[kind.name] ?? 0) + 1;
      budget -= cost;
    }
    return WaveLoadout(waveNumber: waveNumber, unitCounts: counts);
  }
}
