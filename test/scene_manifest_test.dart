// Proves the hand/tool-generated server-side scene manifest parses into
// valid GameScenes and stays in sync with the built-in Dart catalog - same
// role as `content_manifest_test.dart` for tower/unit content.
import 'dart:convert';
import 'dart:io';

import 'package:boomspire/features/game_core/domain/models/game_scene.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scene_manifest.json parses into valid GameScenes', () {
    final raw = File('server/scene_manifest.json').readAsStringSync();
    final decoded = jsonDecode(raw) as List<dynamic>;

    final scenes = decoded
        .map((e) => GameScene.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(scenes, isNotEmpty);
    expect(scenes.map((s) => s.id).toSet(), hasLength(scenes.length));
    for (final s in scenes) {
      expect(s.version, greaterThan(0));
    }
  });

  test('scene_manifest.json covers every built-in scene id', () {
    final raw = File('server/scene_manifest.json').readAsStringSync();
    final decoded = jsonDecode(raw) as List<dynamic>;
    final manifestIds = decoded
        .map((e) => (e as Map<String, dynamic>)['id'] as String)
        .toSet();

    final builtInIds = {
      ...GameScenes.all.map((s) => s.id),
      ...GameScenes.skirmishes.map((s) => s.id),
    };

    expect(manifestIds, builtInIds);
  });
}
