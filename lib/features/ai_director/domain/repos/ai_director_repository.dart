import '../models/battlefield_snapshot.dart';
import '../models/skirmish_directive.dart';
import '../models/strategy_directive.dart';

/// Decides how hard the next wave should hit, using a live LLM (Gemini, via
/// a local proxy that holds the API key) when available, falling back to a
/// deterministic local heuristic otherwise.
abstract class AiDirectorRepository {
  Future<StrategyDirective> planNextWave(BattlefieldSnapshot snapshot);

  /// Decides how the AI opponent should be playing right now in a
  /// [GameMode.skirmish] match - same live-Gemini/local-fallback contract as
  /// [planNextWave].
  Future<SkirmishDirective> planSkirmish(SkirmishSnapshot snapshot);
}
