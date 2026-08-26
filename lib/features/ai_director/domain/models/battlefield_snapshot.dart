/// A compact summary of the battlefield sent to the AI director so it can
/// decide next-wave strategy without needing the full game state.
class TowerSummary {
  const TowerSummary({
    required this.type,
    required this.count,
    required this.avgHpRatio,
  });

  final String type;
  final int count;
  final double avgHpRatio;

  Map<String, dynamic> toJson() => {
    'type': type,
    'count': count,
    'avgHpRatio': double.parse(avgHpRatio.toStringAsFixed(2)),
  };
}

class BattlefieldSnapshot {
  const BattlefieldSnapshot({
    required this.waveNumber,
    required this.totalWaves,
    required this.playerHealth,
    required this.playerGold,
    required this.towerSummaries,
  });

  final int waveNumber;
  final int totalWaves;
  final int playerHealth;
  final int playerGold;
  final List<TowerSummary> towerSummaries;

  Map<String, dynamic> toJson() => {
    'waveNumber': waveNumber,
    'totalWaves': totalWaves,
    'playerHealth': playerHealth,
    'playerGold': playerGold,
    'towers': towerSummaries.map((t) => t.toJson()).toList(),
  };
}
