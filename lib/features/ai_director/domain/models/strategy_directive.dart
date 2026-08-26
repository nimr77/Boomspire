/// Which towers enemies should prioritize this wave, as decided by the AI
/// director (or the local fallback heuristic).
enum FocusHint { nearestTower, weakestTower, rushBase }

FocusHint focusHintFromName(String? name) => switch (name) {
  'weakestTower' => FocusHint.weakestTower,
  'rushBase' => FocusHint.rushBase,
  _ => FocusHint.nearestTower,
};

/// High-level strategy for the upcoming wave: how aggressive/large the
/// spawn should be, which enemy types to lean into, and what enemies should
/// prioritize attacking.
class StrategyDirective {
  const StrategyDirective({
    required this.aggression,
    required this.focusHint,
    required this.compositionBias,
    this.commanderNote = '',
  });

  /// 0 (passive/trickle) to 1 (maximum pressure).
  final double aggression;
  final FocusHint focusHint;

  /// Per-EnemyType-name spawn count multiplier, e.g. {"air": 1.5}.
  final Map<String, double> compositionBias;

  /// Optional flavor text from the AI commander, shown in the HUD.
  final String commanderNote;

  /// Local heuristic used when Gemini is unreachable/unconfigured, so the
  /// game is always fully playable offline.
  factory StrategyDirective.fallback(int waveNumber) {
    final aggression = (0.25 + waveNumber * 0.08).clamp(0.0, 1.0);
    return StrategyDirective(
      aggression: aggression,
      focusHint: waveNumber.isEven
          ? FocusHint.weakestTower
          : FocusHint.nearestTower,
      compositionBias: waveNumber >= 3 ? const {'air': 1.2} : const {},
      commanderNote: 'Standing orders: escalate pressure.',
    );
  }

  factory StrategyDirective.fromJson(Map<String, dynamic> json) {
    final rawBias = json['compositionBias'];
    final bias = <String, double>{};
    if (rawBias is Map) {
      for (final entry in rawBias.entries) {
        final value = entry.value;
        if (value is num) bias[entry.key.toString()] = value.toDouble();
      }
    }
    return StrategyDirective(
      aggression: ((json['aggression'] as num?)?.toDouble() ?? 0.4).clamp(
        0.0,
        1.0,
      ),
      focusHint: focusHintFromName(json['focusHint'] as String?),
      compositionBias: bias,
      commanderNote: json['commanderNote'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'aggression': aggression,
    'focusHint': focusHint.name,
    'compositionBias': compositionBias,
    'commanderNote': commanderNote,
  };
}
