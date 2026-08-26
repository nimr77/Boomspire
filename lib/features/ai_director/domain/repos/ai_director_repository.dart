import '../models/battlefield_snapshot.dart';
import '../models/strategy_directive.dart';

/// Decides how hard the next wave should hit, using a live LLM (Gemini, via
/// a local proxy that holds the API key) when available, falling back to a
/// deterministic local heuristic otherwise.
abstract class AiDirectorRepository {
  Future<StrategyDirective> planNextWave(BattlefieldSnapshot snapshot);
}
