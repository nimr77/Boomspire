import '../enums/attack_target_kind.dart';

export '../enums/attack_target_kind.dart';

/// High-level tuning for how the AI opponent spends its gold this stretch of
/// the match, as decided by the AI director (or the local fallback
/// heuristic).
class SkirmishDirective {
  /// 0 (turtle/stockpile) to 1 (spend down fast/rush units).
  final double aggression;

  /// 0 (spend almost everything on attack units) to 1 (spend heavily on
  /// defensive towers around its own base first).
  final double buildBias;

  /// Which [SkirmishSnapshot.availableUnits] entry (by [UnitRosterEntry.
  /// kind] name) the AI should prioritize producing next, if the director
  /// has an opinion - null defers to [AiSkirmishControllerComponent]'s own
  /// local "counter whatever the player is fielding" heuristic. This is
  /// how the director actually gets to decide *what to build* from the
  /// full roster it was shown, rather than just tuning aggression/
  /// buildBias while a fixed local heuristic always picks the unit kind.
  final String? preferredUnitKind;

  /// How many attack units to mass at the AI's own base before sending them
  /// out together as one squad, instead of trickling out one at a time -
  /// the director's answer to "how big an attack". Always at least 1.
  final int squadSize;

  /// Where a completed attack squad should be sent - the director's answer
  /// to "where to attack".
  final AttackTargetKind attackTarget;

  /// Optional flavor text from the AI commander, shown in the HUD.
  final String commanderNote;

  const SkirmishDirective({
    required this.aggression,
    required this.buildBias,
    this.preferredUnitKind,
    this.squadSize = 3,
    this.attackTarget = AttackTargetKind.enemyBase,
    this.commanderNote = '',
  });

  /// Local heuristic used when Gemini is unreachable/unconfigured, so a
  /// skirmish match is always fully playable offline. Leans defensive early
  /// (while [aiGold] is still building up) and steadily more aggressive as
  /// [aiTowerCount] grows, mirroring [StrategyDirective.fallback]'s
  /// escalating-difficulty shape for wave-defense. Also reacts to the
  /// player's actual fielded army size, not just their tower count: falling
  /// behind on units pushes buildBias up (turtle behind towers instead of
  /// feeding an army it can't win with), while leading on units pushes
  /// aggression up (press the advantage).
  factory SkirmishDirective.fallback(SkirmishSnapshot snapshot) {
    final towerEdge = (snapshot.aiTowerCount - snapshot.playerTowerCount).clamp(
      -3,
      3,
    );
    final unitEdge = (snapshot.aiUnitCount - snapshot.playerUnitCount).clamp(
      -6,
      6,
    );
    final aggression =
        (0.35 +
                snapshot.aiTowerCount * 0.08 -
                towerEdge * 0.05 +
                unitEdge * 0.04)
            .clamp(0.15, 0.9);
    final buildBias = (0.6 - snapshot.aiTowerCount * 0.08 - unitEdge * 0.03)
        .clamp(0.15, 0.6);
    // More aggression => mass a bigger squad before pushing; deliberately
    // left un-tuned by unit/tower edge so a losing AI still eventually
    // throws a real attack instead of trickling units out forever.
    final squadSize = (2 + aggression * 4).round().clamp(1, 6);
    final attackTarget = snapshot.playerTowerCount > 0
        ? AttackTargetKind.weakestEnemyTower
        : AttackTargetKind.enemyBase;
    return SkirmishDirective(
      aggression: aggression,
      buildBias: buildBias,
      // Left null on purpose: offline, AiSkirmishControllerComponent's own
      // player-composition-aware heuristic (see `_pickKind`) already picks
      // a sensible kind, and is better-informed than anything cheap we
      // could compute here from the roster alone.
      squadSize: squadSize,
      attackTarget: attackTarget,
    );
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
      preferredUnitKind: json['preferredUnitKind'] as String?,
      squadSize: ((json['squadSize'] as num?)?.toInt() ?? 3).clamp(1, 8),
      attackTarget: AttackTargetKind.values.firstWhere(
        (v) => v.name == json['attackTarget'],
        orElse: () => AttackTargetKind.enemyBase,
      ),
      commanderNote: json['commanderNote'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'aggression': aggression,
    'buildBias': buildBias,
    if (preferredUnitKind != null) 'preferredUnitKind': preferredUnitKind,
    'squadSize': squadSize,
    'attackTarget': attackTarget.name,
    'commanderNote': commanderNote,
  };
}

/// A compact summary of a skirmish match sent to the AI director so it can
/// decide how the AI opponent should be playing right now, without needing
/// the full game state.
class SkirmishSnapshot {
  final int aiGold;

  final int aiHealth;
  final int playerGold;
  final int playerHealth;
  final int aiTowerCount;
  final int playerTowerCount;
  final int aiUnitCount;
  final int playerUnitCount;

  /// Every unit kind the AI can currently build, and at what cost - see
  /// [UnitRosterEntry]. Always the AI's *full* buildable roster (not just
  /// what it's already produced), so the director can make an informed
  /// "what to build" call.
  final List<UnitRosterEntry> availableUnits;

  const SkirmishSnapshot({
    required this.aiGold,
    required this.aiHealth,
    required this.playerGold,
    required this.playerHealth,
    required this.aiTowerCount,
    required this.playerTowerCount,
    this.aiUnitCount = 0,
    this.playerUnitCount = 0,
    this.availableUnits = const [],
  });

  Map<String, dynamic> toJson() => {
    'aiGold': aiGold,
    'aiHealth': aiHealth,
    'playerGold': playerGold,
    'playerHealth': playerHealth,
    'aiTowerCount': aiTowerCount,
    'playerTowerCount': playerTowerCount,
    'aiUnitCount': aiUnitCount,
    'playerUnitCount': playerUnitCount,
    'availableUnits': availableUnits.map((u) => u.toJson()).toList(),
  };
}

/// One buildable unit kind the AI director is told about in a
/// [SkirmishSnapshot] - lets it (Gemini, or a smarter future fallback)
/// reason about *what to build* from the real roster instead of a fixed
/// local heuristic always making that call alone.
class UnitRosterEntry {
  /// Matches a `UnitKind`'s `.name` - round-tripped back via
  /// [SkirmishDirective.preferredUnitKind].
  final String kind;
  final int cost;
  final bool isVehicle;
  final bool attacksAir;

  const UnitRosterEntry({
    required this.kind,
    required this.cost,
    required this.isVehicle,
    required this.attacksAir,
  });

  factory UnitRosterEntry.fromJson(Map<String, dynamic> json) =>
      UnitRosterEntry(
        kind: json['kind'] as String? ?? '',
        cost: (json['cost'] as num?)?.toInt() ?? 0,
        isVehicle: json['isVehicle'] as bool? ?? false,
        attacksAir: json['attacksAir'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'cost': cost,
    'isVehicle': isVehicle,
    'attacksAir': attacksAir,
  };
}
