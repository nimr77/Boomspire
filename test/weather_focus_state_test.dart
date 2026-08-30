// Proves WeatherFocusState's pure blend-timing logic in isolation, without
// booting a full BoomspireGame - see EnvironmentSettings.sampleBlend
// (map_draft_test.dart) for how the resulting weights actually get turned
// into a rendered/audible weather look.
import 'dart:math';

import 'package:boomspire/features/terrain/domain/models/weather_focus_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeatherFocusState', () {
    test('starts with an even split across every keyframe', () {
      final state = WeatherFocusState.initial(3, Random(1));
      expect(state.weights.length, 3);
      for (final w in state.weights) {
        expect(w, closeTo(1 / 3, 0.0001));
      }
    });

    test('weights always sum to ~1 no matter when sampled', () {
      final rnd = Random(2);
      final state = WeatherFocusState.initial(4, rnd);
      for (var i = 0; i < 2000; i++) {
        state.advance(0.5, 4, rnd);
        expect(state.weights.reduce((a, b) => a + b), closeTo(1.0, 0.001));
      }
    });

    test('a single keyframe never changes - nothing to blend between', () {
      final rnd = Random(3);
      final state = WeatherFocusState.initial(1, rnd);
      final before = [...state.weights];
      state.advance(9999, 1, rnd);
      expect(state.weights, before);
    });

    test('drifts gradually toward a new mix instead of snapping to it', () {
      final rnd = Random(4);
      final state = WeatherFocusState.initial(2, rnd);
      final start = [...state.weights];
      // One small step should move only a little, not jump straight to
      // whatever the next random target turns out to be.
      state.advance(0.1, 2, rnd);
      final afterOneStep = state.weights[0];
      expect((afterOneStep - start[0]).abs(), lessThan(0.2));
    });

    test('eventually reaches a different focus split over enough time', () {
      final rnd = Random(5);
      final state = WeatherFocusState.initial(3, rnd);
      final start = [...state.weights];
      // Comfortably longer than the max shift+transition window so at
      // least one reroll has fully settled.
      for (var i = 0; i < 2000; i++) {
        state.advance(0.5, 3, rnd);
      }
      final changed = List.generate(
        3,
        (i) => (state.weights[i] - start[i]).abs() > 0.01,
      ).any((e) => e);
      expect(changed, isTrue);
    });
  });
}
