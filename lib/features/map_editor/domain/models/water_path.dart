import 'package:freezed_annotation/freezed_annotation.dart';

import 'editor_point.dart';

part 'water_path.freezed.dart';
part 'water_path.g.dart';

/// Whether a hand-drawn water feature is an open flowing channel or a
/// closed body of water.
enum WaterFeatureKind { river, lake }

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
