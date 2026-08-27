/// A compact summary of a skirmish match sent to the AI director so it can
/// decide how the AI opponent should be playing right now, without needing
/// the full game state.
class SkirmishSnapshot {
  const SkirmishSnapshot({
    required this.aiGold,
    required this.aiHealth,
    required this.playerGold,
    required this.playerHealth,
    required this.aiTowerCount,
    required this.playerTowerCount,
  });

  final int aiGold;
  final int aiHealth;
  final int playerGold;
  final int playerHealth;
  final int aiTowerCount;
  final int playerTowerCount;

  Map<String, dynamic> toJson() => {
    'aiGold': aiGold,
    'aiHealth': aiHealth,
    'playerGold': playerGold,
    'playerHealth': playerHealth,
    'aiTowerCount': aiTowerCount,
    'playerTowerCount': playerTowerCount,
  };
}

/// High-level tuning for how the AI opponent spends its gold this stretch of
/// the match, as decided by the AI director (or the local fallback
/// heuristic).
class SkirmishDirective {
  /// 0 (turtle/stockpile) to 1 (spend down fast/rush units).
  final double aggression;

  /// 0 (spend almost everything on attack units) to 1 (spend heavily on
  /// defensive towers around its own base first).
  final double buildBias;

  /// Optional flavor text from the AI commander, shown in the HUD.
  final String commanderNote;

  const SkirmishDirective({
    required this.aggression,
    required this.buildBias,
    this.commanderNote = '',
  });

  /// Local heuristic used when Gemini is unreachable/unconfigured, so a
  /// skirmish match is always fully playable offline. Leans defensive early
  /// (while [aiGold] is still building up) and steadily more aggressive as
  /// [aiTowerCount] grows, mirroring [StrategyDirective.fallback]'s
  /// escalating-difficulty shape for wave-defense.
  factory SkirmishDirective.fallback(SkirmishSnapshot snapshot) {
    final towerEdge = (snapshot.aiTowerCount - snapshot.playerTowerCount)
        .clamp(-3, 3);
    final aggression = (0.35 + snapshot.aiTowerCount * 0.08 - towerEdge * 0.05)
        .clamp(0.15, 0.9);
    final buildBias = (0.6 - snapshot.aiTowerCount * 0.08).clamp(0.15, 0.6);
    return SkirmishDirective(aggression: aggression, buildBias: buildBias);
  }

  factory SkirmishDirective.fromJson(Map<String, dynamic> json) {
    return SkirmishDirective(
      aggression: ((json['aggression'] as num?)?.toDouble() ?? 0.4).clamp(
        0.0,
        1.0,
      ),
      buildBias: ((json['buildBias'] as num?)?.toDouble() ?? 0.4).clamp(
        0.0,
        1.0,
      ),
      commanderNote: json['commanderNote'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'aggression': aggression,
    'buildBias': buildBias,
    'commanderNote': commanderNote,
  };
}
