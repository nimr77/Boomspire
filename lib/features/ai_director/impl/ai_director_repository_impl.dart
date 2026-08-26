import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/models/battlefield_snapshot.dart';
import '../domain/models/strategy_directive.dart';
import '../domain/repos/ai_director_repository.dart';

/// Calls a local proxy server (see `server/gemini_proxy.dart`) which in turn
/// asks Gemini to command the enemy AI. The proxy keeps the Gemini API key
/// server-side - the Flutter client never sees it. If the proxy is
/// unreachable (not running, no API key configured, network error, or slow),
/// this falls back to [StrategyDirective.fallback] so the game is always
/// fully playable without any AI backend.
class AiDirectorRepositoryImpl implements AiDirectorRepository {
  AiDirectorRepositoryImpl({String? proxyUrl})
    : _proxyUrl =
          proxyUrl ??
          const String.fromEnvironment(
            'AI_PROXY_URL',
            defaultValue: 'http://localhost:8787',
          );

  final String _proxyUrl;

  @override
  Future<StrategyDirective> planNextWave(BattlefieldSnapshot snapshot) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_proxyUrl/strategy'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(snapshot.toJson()),
          )
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return StrategyDirective.fromJson(json);
      }
    } catch (_) {
      // Proxy down / no key / network hiccup - silently use the fallback.
    }
    return StrategyDirective.fallback(snapshot.waveNumber);
  }
}
