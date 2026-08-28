import '../models/game_object_definition.dart';

/// Fetches the current game-content manifest from the server (the same
/// proxy used for AI-director strategy calls, see `server/gemini_proxy.dart`).
///
/// Network failures are the caller's problem to decide how to handle (the
/// sync flow treats a failed fetch as "nothing newer available" and keeps
/// whatever's already cached/bundled) - this interface itself just throws.
abstract class GameContentRepository {
  Future<List<GameObjectDefinition>> fetchManifest();
}
