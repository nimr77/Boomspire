import 'dart:math';

FogDriftMetrics fogDriftMetrics(double bobPhase) =>
    (drift: sin(bobPhase) * 14, breathe: 0.75 + 0.25 * sin(bobPhase * 1.3));

/// Vertical drift offset and opacity-breathing factor for one fog bank at
/// [bobPhase], used by `CloudLayerComponent.render`.
typedef FogDriftMetrics = ({double drift, double breathe});
