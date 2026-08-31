import 'dart:math';

CloudDriftMetrics cloudDriftMetrics(double bobPhase) =>
    (drift: sin(bobPhase) * 5, breathe: 0.8 + 0.2 * sin(bobPhase * 1.7));

/// Vertical drift offset and opacity-breathing factor for one cloud puff
/// at [bobPhase], used by `CloudLayerComponent.render`.
typedef CloudDriftMetrics = ({double drift, double breathe});
