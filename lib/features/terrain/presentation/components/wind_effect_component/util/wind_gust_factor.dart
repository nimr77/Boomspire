import 'dart:math';

/// Gust-modulated speed multiplier for one wind particle at [gustPhase],
/// used by `WindEffectComponent.update`.
double windGustFactor(double gustPhase) => 0.7 + 0.3 * sin(gustPhase);
