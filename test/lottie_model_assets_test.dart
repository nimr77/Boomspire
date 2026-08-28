// Loads every generated `assets/models/*.json` through the real `lottie`
// package (not just the Python generator's own round-trip check) - this is
// the closest thing to a visual smoke test available headlessly: it
// actually parses the Bodymovin JSON and rasterizes it via
// `LottieDrawable.draw`, the exact path `LottieUnitRenderRepositoryImpl`
// uses in the game.
import 'dart:io';

import 'package:boomspire/core/rendering/impl/lottie_unit_render_repository_impl.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final keys =
      Directory('assets/models')
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .where((name) => name.endsWith('.json'))
          .map((name) => name.substring(0, name.length - '.json'.length))
          .toList()
        ..sort();

  test('the generator produced at least one model asset', () {
    expect(keys, isNotEmpty);
  });

  for (final key in keys) {
    testWidgets('$key.json bakes to a sprite via the real lottie package', (
      tester,
    ) async {
      final repo = LottieUnitRenderRepositoryImpl();
      final component = await repo.render(
        key: key,
        size: Vector2.all(48),
        fallback: () async => throw StateError('$key.json should have loaded'),
      );
      expect(component, isA<SpriteComponent>());
    });
  }
}
