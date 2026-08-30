import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../terrain/domain/models/biome.dart';

part 'tree_cell.freezed.dart';
part 'tree_cell.g.dart';

/// One hand-placed tree, addressed by terrain grid cell (same col/row space
/// as [PaintedCell]) - unlike a [PaintedCell], a tree is purely decorative
/// and never blocks movement or building, and can be placed on any biome
/// regardless of [BiomePalette.hasTrees].
@freezed
abstract class TreeCell with _$TreeCell {
  const factory TreeCell({
    required int col,
    required int row,

    /// Overrides which [Biome]'s canopy style this one tree renders with,
    /// instead of the map's own biome (e.g. a snow-capped tree dropped
    /// into a desert map) - null means "render with the map's own biome".
    Biome? variant,
  }) = _TreeCell;

  factory TreeCell.fromJson(Map<String, dynamic> json) =>
      _$TreeCellFromJson(json);
}
