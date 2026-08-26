import 'package:dio/dio.dart';

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
  AiDirectorRepositoryImpl({String? proxyUrl, Dio? dio})
    : _proxyUrl =
          proxyUrl ??
          const String.fromEnvironment(
            'AI_PROXY_URL',
            defaultValue: 'http://localhost:8787',
          ),
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 3),
              sendTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
            ),
          );

  final String _proxyUrl;
  final Dio _dio;

  @override
  Future<StrategyDirective> planNextWave(BattlefieldSnapshot snapshot) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_proxyUrl/strategy',
        data: snapshot.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      if (response.statusCode == 200 && response.data != null) {
        return StrategyDirective.fromJson(response.data!);
      }
    } catch (_) {
      // Proxy down / no key / network hiccup - silently use the fallback.
    }
    return StrategyDirective.fallback(snapshot.waveNumber);
  }
}

