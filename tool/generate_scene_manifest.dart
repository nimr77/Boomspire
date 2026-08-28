// One-off generator: dumps the built-in `GameScenes.all`/`.skirmishes`
// catalog to the server's `scene_manifest.json` (served verbatim by
// `server/gemini_proxy.dart`'s `/scene-manifest` route - "the database"
// for now, same as `content_manifest.json`).
//
// Run with: dart run tool/generate_scene_manifest.dart
// Re-run whenever a scene's hardcoded fields change, then bump the
// affected scene's `version` by hand before committing.
import 'dart:convert';
import 'dart:io';

import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';

void main() {
  final scenes = [...GameScenes.all, ...GameScenes.skirmishes];

  final json = const JsonEncoder.withIndent(
    '  ',
  ).convert(scenes.map((s) => s.toJson()).toList());

  File('server/scene_manifest.json').writeAsStringSync('$json\n');

  stdout.writeln('Wrote ${scenes.length} scenes.');
}
