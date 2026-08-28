import 'dart:convert';
import 'dart:io';

import 'package:boomspire/features/game_content/domain/models/game_object_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'generated content_manifest.json parses into valid GameObjectDefinitions',
    () {
      final raw = File('server/content_manifest.json').readAsStringSync();
      final decoded = jsonDecode(raw) as List<dynamic>;

      final definitions = decoded
          .map((e) => GameObjectDefinition.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(definitions, isNotEmpty);
      expect(
        definitions.map((d) => d.id).toSet(),
        hasLength(definitions.length),
      );
      for (final d in definitions) {
        expect(d.version, greaterThan(0));
      }
    },
  );

  test('server and client manifest copies are identical', () {
    final server = File('server/content_manifest.json').readAsStringSync();
    final client = File('assets/game_content/manifest.json').readAsStringSync();
    expect(client, server);
  });
}
