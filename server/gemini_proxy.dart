import 'dart:convert';
import 'dart:io';

import 'package:boomspire/features/ai_director/domain/models/skirmish_directive.dart';
import 'package:boomspire/features/ai_director/domain/models/strategy_directive.dart';

Future<void> main() async {
  final apiKey =
      Platform.environment['GEMINI_API_KEY'] ?? _loadDotEnv()['GEMINI_API_KEY'];
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? _defaultPort;

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('AI director proxy listening on http://localhost:$port');
  stdout.writeln(
    apiKey == null || apiKey.isEmpty
        ? 'GEMINI_API_KEY not set - serving heuristic fallback strategies only.'
        : 'GEMINI_API_KEY detected - will call Gemini for live strategy calls.',
  );

  server.listen((request) => _handle(request, apiKey));
}

/// Local proxy that lets the game ask Gemini how the enemy AI should command
/// the next wave, without ever putting the API key in the Flutter client.
///
/// Run with:
///   GEMINI_API_KEY=your-key dart run server/gemini_proxy.dart
///
/// If GEMINI_API_KEY is unset, or the Gemini call fails/times out, this
/// serves a deterministic heuristic directive instead - the game is fully
/// playable either way.
const _defaultPort = 8787;

const _model = 'gemini-2.0-flash';

Future<StrategyDirective> _askGemini(
  String apiKey,
  Map<String, dynamic> snapshot,
  int waveNumber,
) async {
  final prompt =
      '''
You are the enemy commander AI in a tower-defense game. Battlefield snapshot (JSON):
${jsonEncode(snapshot)}

Decide the strategy for wave $waveNumber. Respond with ONLY a JSON object of this exact shape:
{"aggression": <0..1 float>, "focusHint": "nearestTower"|"weakestTower"|"rushBase", "compositionBias": {"soldier": <float>, "heavySoldier": <float>, "air": <float>}, "commanderNote": "<one short in-character sentence, max 12 words>"}

aggression scales how many enemies spawn and how fast. compositionBias multiplies each enemy type's planned count (1.0 = unchanged, >1 = more of that type). focusHint tells enemies what to prioritize: nearestTower, weakestTower (lowest HP%), or rushBase (mostly ignore towers and run for the base).
''';

  final uri = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
  );
  final client = HttpClient();
  try {
    final request = await client
        .postUrl(uri)
        .timeout(const Duration(seconds: 8));
    request.headers.contentType = ContentType.json;
    request.write(
      jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'responseMimeType': 'application/json'},
      }),
    );
    final response = await request.close().timeout(const Duration(seconds: 8));
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      throw Exception('Gemini HTTP ${response.statusCode}: $body');
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List;
    final text =
        (candidates.first
                as Map<String, dynamic>)['content']['parts'][0]['text']
            as String;
    final json = jsonDecode(_stripCodeFence(text)) as Map<String, dynamic>;
    return StrategyDirective.fromJson(json);
  } finally {
    client.close();
  }
}

Future<SkirmishDirective> _askGeminiSkirmish(
  String apiKey,
  Map<String, dynamic> snapshot,
) async {
  final prompt =
      '''
You are the AI commander in a real-time base-vs-base skirmish game. Match snapshot (JSON), including every unit kind you're currently able to build in `availableUnits` (cost, whether it's a vehicle, whether it can hit air targets):
${jsonEncode(snapshot)}

Decide your commander's posture right now, which unit to build next, and how to attack. Respond with ONLY a JSON object of this exact shape:
{"aggression": <0..1 float>, "buildBias": <0..1 float>, "preferredUnitKind": <the "kind" of one entry from availableUnits, or null>, "squadSize": <1..8 int>, "attackTarget": "enemyBase" or "weakestEnemyTower", "commanderNote": "<one short in-character sentence, max 12 words>"}

aggression: 0 = stockpile gold and turtle, 1 = spend gold immediately on attack units and push the opponent's base. buildBias: 0 = spend almost everything on attack units, 1 = spend heavily on defensive towers around your own base first. preferredUnitKind: pick whichever unit in availableUnits best counters what the player is fielding (e.g. one that attacksAir if they have aircraft up), or null to let the local heuristic choose. squadSize: how many units to mass into one attack wave before sending them out together - bigger when aggression/gold are high. attackTarget: enemyBase to beeline the player's base, weakestEnemyTower to focus down their most damaged tower first.
''';

  final uri = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
  );
  final client = HttpClient();
  try {
    final request = await client
        .postUrl(uri)
        .timeout(const Duration(seconds: 8));
    request.headers.contentType = ContentType.json;
    request.write(
      jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'responseMimeType': 'application/json'},
      }),
    );
    final response = await request.close().timeout(const Duration(seconds: 8));
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      throw Exception('Gemini HTTP ${response.statusCode}: $body');
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List;
    final text =
        (candidates.first
                as Map<String, dynamic>)['content']['parts'][0]['text']
            as String;
    final json = jsonDecode(_stripCodeFence(text)) as Map<String, dynamic>;
    return SkirmishDirective.fromJson(json);
  } finally {
    client.close();
  }
}

Future<void> _handle(HttpRequest request, String? apiKey) async {
  request.response.headers
    ..set('Access-Control-Allow-Origin', '*')
    ..set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    ..set('Access-Control-Allow-Headers', 'Content-Type');

  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  if (request.method == 'POST' && request.uri.path == '/skirmish') {
    await _handleSkirmish(request, apiKey);
    return;
  }

  if (request.method == 'GET' && request.uri.path == '/content-manifest') {
    await _handleContentManifest(request);
    return;
  }

  if (request.method == 'GET' && request.uri.path == '/scene-manifest') {
    await _handleSceneManifest(request);
    return;
  }

  if (request.method != 'POST' || request.uri.path != '/strategy') {
    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
    return;
  }

  var waveNumber = 1;
  try {
    final body = await utf8.decoder.bind(request).join();
    final snapshot = jsonDecode(body) as Map<String, dynamic>;
    waveNumber = (snapshot['waveNumber'] as num?)?.toInt() ?? 1;

    final directive = (apiKey != null && apiKey.isNotEmpty)
        ? await _askGemini(apiKey, snapshot, waveNumber)
        : StrategyDirective.fallback(waveNumber);

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(directive.toJson()));
  } catch (e) {
    stderr.writeln('AI director proxy falling back after error: $e');
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(StrategyDirective.fallback(waveNumber).toJson()));
  } finally {
    await request.response.close();
  }
}

/// Serves the versioned game-object manifest straight from disk - a plain
/// JSON file for now (see `tool/generate_content_manifest.dart`), until a
/// real database backs it.
Future<void> _handleContentManifest(HttpRequest request) async {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final file = File('${scriptDir.path}/content_manifest.json');
  if (!file.existsSync()) {
    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
    return;
  }

  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.json
    ..write(await file.readAsString());
  await request.response.close();
}

/// Serves the versioned scene/map manifest straight from disk - a plain
/// JSON file for now (see `tool/generate_scene_manifest.dart`), same
/// per-file-until-a-real-database approach as `_handleContentManifest`.
Future<void> _handleSceneManifest(HttpRequest request) async {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final file = File('${scriptDir.path}/scene_manifest.json');
  if (!file.existsSync()) {
    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
    return;
  }

  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.json
    ..write(await file.readAsString());
  await request.response.close();
}

Future<void> _handleSkirmish(HttpRequest request, String? apiKey) async {
  Map<String, dynamic> snapshot = const {};
  try {
    final body = await utf8.decoder.bind(request).join();
    snapshot = jsonDecode(body) as Map<String, dynamic>;

    final directive = (apiKey != null && apiKey.isNotEmpty)
        ? await _askGeminiSkirmish(apiKey, snapshot)
        : SkirmishDirective.fallback(_snapshotFromJson(snapshot));

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(directive.toJson()));
  } catch (e) {
    stderr.writeln('AI director proxy falling back after error: $e');
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(
        jsonEncode(
          SkirmishDirective.fallback(_snapshotFromJson(snapshot)).toJson(),
        ),
      );
  } finally {
    await request.response.close();
  }
}

/// Minimal KEY=VALUE parser for `server/.env`, resolved relative to this
/// script so it works no matter what directory `dart run` is invoked from.
Map<String, String> _loadDotEnv() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final file = File('${scriptDir.path}/.env');
  if (!file.existsSync()) return const {};

  final values = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final eq = trimmed.indexOf('=');
    if (eq <= 0) continue;
    var value = trimmed.substring(eq + 1).trim();
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1);
    }
    values[trimmed.substring(0, eq).trim()] = value;
  }
  return values;
}

SkirmishSnapshot _snapshotFromJson(Map<String, dynamic> json) =>
    SkirmishSnapshot(
      aiGold: (json['aiGold'] as num?)?.toInt() ?? 0,
      aiHealth: (json['aiHealth'] as num?)?.toInt() ?? 0,
      playerGold: (json['playerGold'] as num?)?.toInt() ?? 0,
      playerHealth: (json['playerHealth'] as num?)?.toInt() ?? 0,
      aiTowerCount: (json['aiTowerCount'] as num?)?.toInt() ?? 0,
      playerTowerCount: (json['playerTowerCount'] as num?)?.toInt() ?? 0,
      aiUnitCount: (json['aiUnitCount'] as num?)?.toInt() ?? 0,
      playerUnitCount: (json['playerUnitCount'] as num?)?.toInt() ?? 0,
      availableUnits:
          (json['availableUnits'] as List?)
              ?.map((u) => UnitRosterEntry.fromJson(u as Map<String, dynamic>))
              .toList() ??
          const [],
    );

String _stripCodeFence(String text) {
  final trimmed = text.trim();
  if (!trimmed.startsWith('```')) return trimmed;
  return trimmed
      .replaceFirst(RegExp(r'^```[a-zA-Z]*\n?'), '')
      .replaceFirst(RegExp(r'```$'), '')
      .trim();
}
