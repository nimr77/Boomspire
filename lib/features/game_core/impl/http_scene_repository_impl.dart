import 'package:dio/dio.dart';

import '../domain/models/game_scene.dart';
import '../domain/repos/scene_repository.dart';

/// Fetches the scene/map manifest from the local proxy server - see
/// `server/gemini_proxy.dart`'s `GET /scene-manifest` route.
///
/// Mirrors `HttpGameContentRepositoryImpl`'s proxy-url/timeout setup so
/// every repo hits the same local server the same way.
class HttpSceneRepositoryImpl implements SceneRepository {
  final String _proxyUrl;
  final Dio _dio;

  HttpSceneRepositoryImpl({String? proxyUrl, Dio? dio})
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
  Future<List<GameScene>> fetchManifest() async {
    final response = await _dio.get<List<dynamic>>('$_proxyUrl/scene-manifest');
    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      throw StateError(
        'GET $_proxyUrl/scene-manifest failed with status ${response.statusCode}',
      );
    }
    return data
        .map((e) => GameScene.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
