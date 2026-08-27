import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/combat/unit_kind.dart';

part 'wave_loadout.freezed.dart';
part 'wave_loadout.g.dart';

/// The AI's hand-authored (or randomized) spawn budget for one wave number -
/// how many of each [UnitKind] it gets to spend attacking the player that
/// round, instead of a fixed formula. Keyed by [UnitKind.name] since plain
/// enums can't be JSON map keys directly. Authored per-wave in the map
/// editor; a wave number with no matching [WaveLoadout] (or an empty one)
/// falls back to the procedural default (see `DraftWaveRepository`).
@freezed
abstract class WaveLoadout with _$WaveLoadout {
  const factory WaveLoadout({
    required int waveNumber,
    @Default(<String, int>{}) Map<String, int> unitCounts,
  }) = _WaveLoadout;

  factory WaveLoadout.fromJson(Map<String, dynamic> json) =>
      _$WaveLoadoutFromJson(json);

  const WaveLoadout._();

  int countOf(UnitKind kind) => unitCounts[kind.name] ?? 0;

  WaveLoadout withCount(UnitKind kind, int count) {
    final updated = {...unitCounts};
    if (count <= 0) {
      updated.remove(kind.name);
    } else {
      updated[kind.name] = count;
    }
    return copyWith(unitCounts: updated);
  }

  int get totalUnits => unitCounts.values.fold(0, (sum, c) => sum + c);
}
