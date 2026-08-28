import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/water_feature_kind.dart';
import 'editor_point.dart';

export '../enums/water_feature_kind.dart';

part 'water_path.freezed.dart';
part 'water_path.g.dart';

/// A freehand-drawn river or lake from the map editor's water tool.
///
/// [points] is the drawn stroke: an open polyline for [WaterFeatureKind.river]
/// (rasterized as a channel [width] wide) or a closed loop for
/// [WaterFeatureKind.lake] (rasterized as a filled polygon - [width] is
/// unused for lakes).
@freezed
abstract class WaterPath with _$WaterPath {
  const factory WaterPath({
    required WaterFeatureKind kind,
    required List<EditorPoint> points,
    @Default(48.0) double width,
  }) = _WaterPath;

  factory WaterPath.fromJson(Map<String, dynamic> json) =>
      _$WaterPathFromJson(json);
}
