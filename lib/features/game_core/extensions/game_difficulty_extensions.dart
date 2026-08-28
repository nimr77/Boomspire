import '../../../generated/l10n.dart';
import '../domain/enums/game_difficulty.dart';

extension GameDifficultyExtensions on GameDifficulty {
  /// Multiplies the AI director's (or its offline fallback's) computed
  /// aggression - harder difficulties mean bigger, faster waves on top of
  /// whatever the director already decided for the wave/scene.
  double get aggressionMultiplier => switch (this) {
    GameDifficulty.easy => 0.7,
    GameDifficulty.normal => 1.0,
    GameDifficulty.hard => 1.4,
  };

  String get label => switch (this) {
    GameDifficulty.easy => S.current.difficultyLabelEasy,
    GameDifficulty.normal => S.current.difficultyLabelNormal,
    GameDifficulty.hard => S.current.difficultyLabelHard,
  };
}
