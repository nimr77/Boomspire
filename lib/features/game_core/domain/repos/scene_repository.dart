import '../models/game_scene.dart';

/// Fetches the current scene/map manifest from the server (the same proxy
/// used for AI-director strategy calls and the tower/unit content manifest -
/// see `server/gemini_proxy.dart`).
///
/// Covers both wave-defense and skirmish scenes in one list, same as
/// `GameScenes.all`/`GameScenes.skirmishes` combined - a network failure is
/// the caller's problem to decide how to handle (see `SceneSyncService`,
/// which treats it as "nothing newer available").
abstract class SceneRepository {
  Future<List<GameScene>> fetchManifest();
}
