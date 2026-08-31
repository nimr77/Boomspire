import 'dart:math';

/// Sine-wave vertical bob offset for one wind particle at [bobPhase], used
/// by `WindEffectComponent.render`.
double windParticleBob(double bobPhase) => sin(bobPhase) * 2;
