import 'package:dio/dio.dart';

import '../domain/models/game_object_definition.dart';
import '../domain/repos/game_content_repository.dart';

/// Fetches the game-content manifest from the local proxy server (the same
/// one used for AI-director strategy calls - see `server/gemini_proxy.dart`,
/// which needs a `GET /content-manifest` route added alongside its existing
/// `/strategy`/`/skirmish` routes).
///
/// Mirrors `AiDirectorRepositoryImpl`'s proxy-url/timeout setup so both
/// repos hit the same local server the same way.
class HttpGameContentRepositoryImpl implements GameContentRepository {
  final String _proxyUrl;
  final Dio _dio;

  HttpGameContentRepositoryImpl({String? proxyUrl, Dio? dio})
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

  @override
  Future<List<GameObjectDefinition>> fetchManifest() async {
    final response = await _dio.get<List<dynamic>>('$_proxyUrl/content-manifest');
    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      throw StateError(
        'GET $_proxyUrl/content-manifest failed with status ${response.statusCode}',
      );
    }
    return data
        .map((e) => GameObjectDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
