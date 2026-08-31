import 'dart:math';

RiverFlowGlintMetrics riverFlowGlintMetrics({
  required double phase,
  required int index,
  required double dist,
  required double length,
}) {
  final pulse = 0.5 + 0.5 * sin(phase * 2.0 + index * 1.3);
  final fadeMargin = length * 0.12;
  final edgeFade = dist < fadeMargin
      ? dist / fadeMargin
      : dist > length - fadeMargin
      ? (length - dist) / fadeMargin
      : 1.0;
  return (pulse: pulse, edgeFade: edgeFade);
}

/// Pulse brightness and edge-fade for one shimmering glint drifting along
/// the river flow in `TerrainPainter.paintRiverFlow` - [edgeFade] ramps the
/// glint in/out near the path's wrap point instead of letting it teleport
/// back to the start at full brightness.
typedef RiverFlowGlintMetrics = ({double pulse, double edgeFade});
