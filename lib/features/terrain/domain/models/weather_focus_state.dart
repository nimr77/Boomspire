import 'dart:math';

import '../../../game_core/domain/models/game_config.dart';

/// Runtime engine behind a live match's weather "mood" - instead of
/// picking a single point along `EnvironmentSettings.timeline` by match
/// progress (see `EnvironmentSettings.sample`), every keyframe gets a
/// "focus" weight (0..1, all weights sum to ~1 - e.g. keyframe 0 at 60%,
/// keyframe 1 at 10%, keyframe 2 at 30%) and [EnvironmentSettings.sampleBlend]
/// mixes all of them by those weights.
///
/// [advance] re-rolls [weights] to a brand new random split at a random
/// interval (`GameConfig.weatherFocusMinShiftSeconds`/
/// `weatherFocusMaxShiftSeconds`, capped at 5 minutes per design), always
/// easing smoothly toward the new split over a further random
/// `GameConfig.weatherFocusTransitionMinSeconds`/`MaxSeconds` rather than
/// snapping straight to it, so the look/sound drifts naturally instead of
/// visibly cutting like a slide change.
class WeatherFocusState {
  /// Current per-keyframe blend weight (same order/length as
  /// `EnvironmentSettings.timeline`) - read every frame by
  /// [EnvironmentSettings.sampleBlend].
  List<double> weights;

  List<double> _fromWeights;
  List<double> _targetWeights;
  double _transitionElapsed;
  double _transitionDuration;
  double _secondsUntilNextShift;

  /// An even starting split across [keyframeCount] keyframes, with its
  /// first random reroll already scheduled via [rnd].
  factory WeatherFocusState.initial(int keyframeCount, Random rnd) {
    final even = _evenWeights(keyframeCount);
    return WeatherFocusState._(
      weights: [...even],
      fromWeights: [...even],
      targetWeights: _randomWeights(keyframeCount, rnd),
      transitionElapsed: 0,
      transitionDuration: _randomTransitionSeconds(rnd),
      secondsUntilNextShift: _randomShiftSeconds(rnd),
    );
  }

  WeatherFocusState._({
    required this.weights,
    required this._fromWeights,
    required this._targetWeights,
    required this._transitionElapsed,
    required this._transitionDuration,
    required this._secondsUntilNextShift,
  });

  /// Advances the blend by [dt] seconds. A no-op once [keyframeCount] is 0
  /// or 1 - there's nothing to blend between.
  void advance(double dt, int keyframeCount, Random rnd) {
    if (keyframeCount <= 1) return;

    _secondsUntilNextShift -= dt;
    if (_secondsUntilNextShift <= 0) {
      // Snapshot the in-progress blend (not necessarily fully settled on
      // the old target yet) as the new starting point, so locking in the
      // next random mood never causes a visible jump.
      _fromWeights = [...weights];
      _targetWeights = _randomWeights(keyframeCount, rnd);
      _transitionElapsed = 0;
      _transitionDuration = _randomTransitionSeconds(rnd);
      _secondsUntilNextShift = _randomShiftSeconds(rnd);
    } else {
      _transitionElapsed = (_transitionElapsed + dt).clamp(
        0.0,
        _transitionDuration,
      );
    }

    final t = _transitionDuration <= 0
        ? 1.0
        : (_transitionElapsed / _transitionDuration).clamp(0.0, 1.0);
    final eased = t * t * (3 - 2 * t); // smoothstep - organic, not linear
    weights = [
      for (var i = 0; i < keyframeCount; i++)
        _lerp(_fromWeights[i], _targetWeights[i], eased),
    ];
  }

  static List<double> _evenWeights(int count) =>
      count <= 0 ? const [] : List.filled(count, 1 / count);

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static double _randomShiftSeconds(Random rnd) =>
      GameConfig.weatherFocusMinShiftSeconds +
      rnd.nextDouble() *
          (GameConfig.weatherFocusMaxShiftSeconds -
              GameConfig.weatherFocusMinShiftSeconds);

  static double _randomTransitionSeconds(Random rnd) =>
      GameConfig.weatherFocusTransitionMinSeconds +
      rnd.nextDouble() *
          (GameConfig.weatherFocusTransitionMaxSeconds -
              GameConfig.weatherFocusTransitionMinSeconds);

  /// A uniformly-random split of 1.0 across [count] shares (a Dirichlet(1)
  /// draw via the standard exponential-sampling trick) - naturally
  /// produces varied, sometimes lopsided splits like "60% / 10% / 30%"
  /// rather than everything hovering near an even share every time.
  static List<double> _randomWeights(int count, Random rnd) {
    if (count <= 0) return const [];
    if (count == 1) return [1.0];
    final raw = List<double>.generate(count, (_) => -log(1 - rnd.nextDouble()));
    final total = raw.reduce((a, b) => a + b);
    return [for (final v in raw) v / total];
  }
}
