import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../game_core/domain/models/game_scene.dart';
import '../../../terrain/domain/models/biome.dart';
import 'environment_settings.dart';
import 'painted_cell.dart';
import 'water_path.dart';

part 'map_draft.freezed.dart';
part 'map_draft.g.dart';

/// A user-authored map, built in the in-app map editor.
///
/// Purely a data draft - hand-placed home sites and resource nodes (needed
/// once a draft targets [GameMode.skirmish]) are added by a later editor
/// pass; this shape only covers terrain, water and environment so far. Use
/// `EditorTerrainGenerator` to rasterize a draft into a renderable preview.
@freezed
abstract class MapDraft with _$MapDraft {
  const factory MapDraft({
    required String id,
    required String name,
    @Default(Biome.grassPlains) Biome biome,
    @Default(GameMode.waveDefense) GameMode mode,
    @Default(1280.0) double arenaWidth,
    @Default(720.0) double arenaHeight,
    @Default([]) List<PaintedCell> paintedCells,
    @Default([]) List<WaterPath> waterPaths,
    @Default(EnvironmentSettings()) EnvironmentSettings environment,
  }) = _MapDraft;

  factory MapDraft.fromJson(Map<String, dynamic> json) =>
      _$MapDraftFromJson(json);
}
