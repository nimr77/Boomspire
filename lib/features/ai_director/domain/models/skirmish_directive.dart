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

  /// Every unit kind the AI can currently build, and at what cost/combat
  /// profile - see [UnitRosterEntry]. Always the AI's *full* buildable
  /// roster (not just what it's already produced), so the director can
  /// make an informed "what to build" call grounded in real stats (damage,
  /// range, speed) rather than just a name and a price.
  final List<UnitRosterEntry> availableUnits;

  /// Every tower/building the AI can build, with its own cost/combat
  /// profile - see [TowerRosterEntry]. Lets the director reason about the
  /// AI's defensive options (range, firepower, what domain they can hit)
  /// alongside its unit roster, instead of only ever seeing raw counts.
  final List<TowerRosterEntry> availableTowers;

  /// A top-down read of the battlefield grid, one string per row, `#` for
  /// blocked (mountain or an occupied cell) and `.` for open ground - the
  /// director's answer to "read the blocks on the screen". Empty when the
  /// caller didn't supply one (e.g. an older client or a test).
  final List<String> terrainRows;

  /// Grid column/row of the AI's own base within [terrainRows] - null if
  /// unknown.
  final int? aiBaseCol;
  final int? aiBaseRow;

  /// Grid column/row of the player's base within [terrainRows] - null if
  /// unknown.
  final int? playerBaseCol;
  final int? playerBaseRow;

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
    this.availableTowers = const [],
    this.terrainRows = const [],
    this.aiBaseCol,
    this.aiBaseRow,
    this.playerBaseCol,
    this.playerBaseRow,
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
    'availableTowers': availableTowers.map((t) => t.toJson()).toList(),
    if (terrainRows.isNotEmpty) 'terrainRows': terrainRows,
    if (aiBaseCol != null) 'aiBaseCol': aiBaseCol,
    if (aiBaseRow != null) 'aiBaseRow': aiBaseRow,
    if (playerBaseCol != null) 'playerBaseCol': playerBaseCol,
    if (playerBaseRow != null) 'playerBaseRow': playerBaseRow,
  };
}

/// One buildable tower/building kind the AI director is told about in a
/// [SkirmishSnapshot] - the defensive/economic counterpart of
/// [UnitRosterEntry], so the director understands the AI's structures'
/// firepower and range too, not just its mobile units. A non-combat
/// building (Gold Mine, Training Center, ...) simply has `damage`/`range`
/// of 0.
class TowerRosterEntry {
  /// Matches a `BuildingType`/`TowerType`'s `.name`.
  final String type;
  final int cost;
  final double damage;
  final double range;
  final double maxHp;
  final bool attacksAir;
  final bool attacksGround;

  const TowerRosterEntry({
    required this.type,
    required this.cost,
    required this.damage,
    required this.range,
    required this.maxHp,
    required this.attacksAir,
    required this.attacksGround,
  });

  factory TowerRosterEntry.fromJson(Map<String, dynamic> json) =>
      TowerRosterEntry(
        type: json['type'] as String? ?? '',
        cost: (json['cost'] as num?)?.toInt() ?? 0,
        damage: (json['damage'] as num?)?.toDouble() ?? 0,
        range: (json['range'] as num?)?.toDouble() ?? 0,
        maxHp: (json['maxHp'] as num?)?.toDouble() ?? 0,
        attacksAir: json['attacksAir'] as bool? ?? false,
        attacksGround: json['attacksGround'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
    'type': type,
    'cost': cost,
    'damage': damage,
    'range': range,
    'maxHp': maxHp,
    'attacksAir': attacksAir,
    'attacksGround': attacksGround,
  };
}

/// One buildable unit kind the AI director is told about in a
/// [SkirmishSnapshot] - lets it (Gemini, or a smarter future fallback)
/// reason about *what to build* from the real roster instead of a fixed
/// local heuristic always making that call alone. Carries the same combat
/// profile a human player would read off the build menu tooltip - cost,
/// domain, firepower, and range - not just a name.
class UnitRosterEntry {
  /// Matches a `UnitKind`'s `.name` - round-tripped back via
  /// [SkirmishDirective.preferredUnitKind].
  final String kind;
  final int cost;
  final bool isVehicle;
  final bool attacksAir;

  /// This unit's own physical domain - `"ground"`, `"air"`, or `"sea"` (see
  /// `UnitDomain`).
  final String domain;

  /// Damage dealt per clip when this unit engages a target.
  final double damage;

  /// World-pixel range at which this unit stops to fire.
  final double range;

  /// World pixels per second this unit moves at.
  final double speed;

  const UnitRosterEntry({
    required this.kind,
    required this.cost,
    required this.isVehicle,
    required this.attacksAir,
    this.domain = 'ground',
    this.damage = 0,
    this.range = 0,
    this.speed = 0,
  });

  factory UnitRosterEntry.fromJson(Map<String, dynamic> json) =>
      UnitRosterEntry(
        kind: json['kind'] as String? ?? '',
        cost: (json['cost'] as num?)?.toInt() ?? 0,
        isVehicle: json['isVehicle'] as bool? ?? false,
        attacksAir: json['attacksAir'] as bool? ?? false,
        domain: json['domain'] as String? ?? 'ground',
        damage: (json['damage'] as num?)?.toDouble() ?? 0,
        range: (json['range'] as num?)?.toDouble() ?? 0,
        speed: (json['speed'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'cost': cost,
    'isVehicle': isVehicle,
    'attacksAir': attacksAir,
    'domain': domain,
    'damage': damage,
    'range': range,
    'speed': speed,
  };
}
