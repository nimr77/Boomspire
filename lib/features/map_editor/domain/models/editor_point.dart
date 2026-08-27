import 'package:freezed_annotation/freezed_annotation.dart';

part 'editor_point.freezed.dart';
part 'editor_point.g.dart';

/// A single world-space point drawn in the map editor (freehand river/lake
/// paths). Plain data - kept separate from `dart:ui`'s `Offset` so it stays
/// trivially JSON-serializable.
@freezed
abstract class EditorPoint with _$EditorPoint {
  const factory EditorPoint({required double x, required double y}) =
      _EditorPoint;

  factory EditorPoint.fromJson(Map<String, dynamic> json) =>
      _$EditorPointFromJson(json);
}
