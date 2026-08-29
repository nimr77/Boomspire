import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../terrain/domain/models/biome.dart';
import '../../../terrain/domain/models/obstacle_kind.dart';

part 'painted_cell.freezed.dart';
part 'painted_cell.g.dart';

/// One grid cell hand-painted with an obstacle brush (mountain/dune) in the
/// map editor - rivers/lakes are drawn freehand instead (see [WaterPath]),
/// not painted cell-by-cell.
@freezed
abstract class PaintedCell with _$PaintedCell {
  const factory PaintedCell({
    required int col,
    required int row,
    required ObstacleKind kind,

    /// Overrides which [Biome]'s palette this one obstacle renders with,
    /// instead of the map's own biome (e.g. a snow-capped mountain dropped
    /// into a desert map) - null means "render with the map's own biome",
    /// matching every cell painted before this brush-type feature existed.
    Biome? variant,
  }) = _PaintedCell;

  factory PaintedCell.fromJson(Map<String, dynamic> json) =>
      _$PaintedCellFromJson(json);
}
