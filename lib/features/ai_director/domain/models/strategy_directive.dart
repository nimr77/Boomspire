FocusHint focusHintFromName(String? name) => switch (name) {
  'weakestTower' => FocusHint.weakestTower,
  'rushBase' => FocusHint.rushBase,
  'clearObstacles' => FocusHint.clearObstacles,
  _ => FocusHint.nearestTower,
};

/// Which towers enemies should prioritize this wave, as decided by the AI
/// director (or the local fallback heuristic). `clearObstacles` makes
/// enemies detour and prioritize destroying any tower blocking their path
/// to the base (rather than just the nearest/weakest one), widening their
/// detection range so they'll go out of their way to do it.
enum FocusHint { nearestTower, weakestTower, rushBase, clearObstacles }

/// High-level strategy for the upcoming wave: how aggressive/large the
/// spawn should be, which enemy types to lean into, and what enemies should
/// prioritize attacking.
class StrategyDirective {
  /// 0 (passive/trickle) to 1 (maximum pressure).
  final double aggression;

  final FocusHint focusHint;

  /// Per-EnemyType-name spawn count multiplier, e.g. {"air": 1.5}.
  final Map<String, double> compositionBias;

  /// Optional flavor text from the AI commander, shown in the HUD.
  final String commanderNote;

  const StrategyDirective({
    required this.aggression,
    required this.focusHint,
    required this.compositionBias,
    this.commanderNote = '',
  });

  /// Local heuristic used when Gemini is unreachable/unconfigured, so the
  /// game is always fully playable offline.
  factory StrategyDirective.fallback(int waveNumber) {
    final aggression = (0.25 + waveNumber * 0.08).clamp(0.0, 1.0);
    final FocusHint focusHint;
    if (waveNumber % 5 == 0) {
      focusHint = FocusHint.clearObstacles;
    } else if (waveNumber.isEven) {
      focusHint = FocusHint.weakestTower;
    } else {
      focusHint = FocusHint.nearestTower;
    }
    final compositionBias = <String, double>{};
    if (waveNumber >= 3) compositionBias['attackPlane'] = 1.2;
    if (waveNumber >= 5) compositionBias['tank'] = 1.3;
    if (waveNumber >= 7) compositionBias['artilleryBarrage'] = 1.4;
    if (waveNumber >= 9) compositionBias['rocketBarrage'] = 1.4;
    return StrategyDirective(
      aggression: aggression,
      focusHint: focusHint,
      compositionBias: compositionBias,
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
