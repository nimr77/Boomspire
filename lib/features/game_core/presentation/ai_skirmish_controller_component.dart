import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';

import '../../../core/combat/attackable.dart';
import '../../../core/combat/enums/unit_domain.dart';
import '../../../core/combat/team.dart';
import '../../../core/combat/unit_kind.dart';
import '../../../core/combat/unit_objective.dart';
import '../../ai_director/domain/models/skirmish_directive.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/domain/models/tower_type.dart';
import '../../towers/domain/models/unit_type.dart';
import '../../towers/presentation/training_center_component.dart';
import '../../towers/presentation/war_factory_component.dart';
import '../domain/models/game_status.dart';
import 'boomspire_game.dart';

class AiSkirmishControllerComponent extends Component
    with HasGameReference<BoomspireGame> {
  static const _directiveInterval = 14.0;
  static const _decisionInterval = 3.0;

  /// Purely a pacing/performance safety valve (an autonomous AI never gets
  /// tired of clicking "build"), not a capability nerf - a human player is
  /// just as free to build this many structures given enough gold and time.
  static const _maxOwnStructures = 24;

  /// Tried in this order before any combat tower - economy/production first
  /// (a Gold Mine and a Training Center/War Factory are what actually let
  /// the AI field units and snowball its income), Tech Lab/Command Post
  /// last since those only unlock optional extra towers. This is the
  /// [_CommanderPersona.infantry]/[_CommanderPersona.balanced] order; see
  /// [_infrastructureOrder] for the [_CommanderPersona.rushesWarFactory]
  /// swap.
  static const _infrastructureBuildOrder = [
    BuildingType.goldMine,
    BuildingType.trainingCenter,
    BuildingType.warFactory,
    BuildingType.powerPlant,
    BuildingType.techLab,
    BuildingType.commandPost,
  ];

  /// How many of each production building the AI actively wants before it
  /// stops treating "build another one" as a priority. [BuildingType.
  /// trainingCenter]/[BuildingType.warFactory] have no game-wide build cap
  /// (see [BoomspireGame.buildLimitFor]), so without this heuristic ceiling
  /// the infrastructure-first ordering above would keep re-selecting
  /// "build another one" forever whenever it's affordable - sinking every
  /// spare coin into more empty production buildings and never actually
  /// manning them to roll out units (the reported "builds buildings but
  /// never units" bug). A building not listed here (Gold Mine/Tech
  /// Lab/Command Post) already has its own hard cap of 1 from the game
  /// itself, so it doesn't need an entry.
  static const _productionBuildingTargets = {
    BuildingType.trainingCenter: 2,
    BuildingType.warFactory: 2,
  };

  static const _combatTowerTypes = [
    TowerType.machineGun,
    TowerType.rocket,
    TowerType.cannon,
    TowerType.antiAir,
    TowerType.laser,
    TowerType.rocketSilo,
    TowerType.artilleryBunker,
    TowerType.sam,
  ];

  /// Baseline number of combat towers the AI keeps garrisoned around its
  /// own base for defense - built ahead of the [_directive.buildBias] coin
  /// toss that otherwise gates "extra" towers once this floor is met.
  static const _baseDefenseTowerTarget = 3;

  /// Hostile units within this radius of the AI's own base count as an
  /// active assault on it, temporarily raising the defense-tower target and
  /// making the AI's next build a domain-appropriate counter tower instead
  /// of a coin toss.
  static const _threatRadius = 420.0;

  static const _maxRequiredSquadSize = 12;

  static const _attackEvaluationDelay = 10.0;

  /// This match's persona (see [_CommanderPersona]) - rolled once when the
  /// controller is created and held for the whole skirmish, same as a
  /// human wouldn't change their whole strategic identity mid-match.
  final _CommanderPersona _persona = _CommanderPersona
      .values[Random().nextInt(_CommanderPersona.values.length)];
  double _directiveTimer = _directiveInterval * 0.2;
  double _decisionTimer = _decisionInterval * 0.5;
  bool _fetchingDirective = false;

  SkirmishDirective _directive = const SkirmishDirective(
    aggression: 0.35,
    buildBias: 0.5,
  );

  /// Attack units produced this "wave" that are being held near the AI's
  /// own base (see [_tryProduce]) until [_requiredSquadSize] of them are
  /// ready, at which point [_dispatchAttackSquad] sends them all at
  /// [SkirmishDirective.attackTarget] together - the AI's answer to "how
  /// many units, attacking where" instead of each one trickling off alone
  /// the instant it's produced.
  final List<MobileUnitComponent> _stagedAttackers = [];

  /// The squad size the AI currently insists on before dispatching an
  /// attack - starts at [SkirmishDirective.squadSize] each tick, but grows
  /// (see [_evaluateLastAttack]) once a dispatched squad is wiped out
  /// without making any real progress against its target, so a repelled
  /// assault gets rebuilt bigger before trying again instead of throwing
  /// another same-sized (and equally doomed) squad at the same defenses.
  int _requiredSquadSize = 0;

  /// Bookkeeping for [_evaluateLastAttack]: the target and units of the
  /// most recently dispatched squad, and how long to wait before judging
  /// whether that attack actually accomplished anything. Null/empty once
  /// there's no outstanding attack to evaluate.
  Attackable? _pendingAttackTarget;

  double _pendingAttackTargetHealthRatio = 1.0;
  List<MobileUnitComponent> _pendingAttackUnits = const [];
  double _pendingAttackTimer = 0;
  final Random _rnd = Random();

  /// The squad size actually required before [update] dispatches the
  /// staged attackers - the directive's requested size, or [_requiredSquadSize]
  /// once a previous attack failed and demanded a bigger follow-up, whichever
  /// is larger.
  int get _effectiveSquadSize => max(_directive.squadSize, _requiredSquadSize);

  /// [_infrastructureBuildOrder], with the Training Center/War Factory
  /// swapped for a persona (see [_CommanderPersona]) that rushes vehicles
  /// or aircraft - both only ever come out of a War Factory, so an
  /// [_CommanderPersona.armored]/[_CommanderPersona.airborne] AI wants that
  /// building first instead of infantry's Training Center.
  List<BuildingType> get _infrastructureOrder {
    if (!_persona.rushesWarFactory) return _infrastructureBuildOrder;
    return const [
      BuildingType.goldMine,
      BuildingType.warFactory,
      BuildingType.trainingCenter,
      BuildingType.powerPlant,
      BuildingType.techLab,
      BuildingType.commandPost,
    ];
  }

  @override
  void update(double dt) {
    super.update(dt);
    final economy = game.aiEconomy;
    final aiTeam = game.aiTeam;
    if (economy == null || aiTeam == null || economy.isDefeated) return;
    if (game.gameState.status != GameStatus.playing) return;

    _directiveTimer += dt;
    if (_directiveTimer >= _directiveInterval && !_fetchingDirective) {
      _directiveTimer = 0;
      unawaited(_refreshDirective());
    }

    _decisionTimer += dt;
    if (_decisionTimer >= _decisionInterval) {
      _decisionTimer = 0;
      final justBuilt = _tryBuild(aiTeam);
      // A Training Center/War Factory built just this tick hasn't even
      // mounted/rendered yet, so never let it also produce/capture-dispatch
      // in that same tick - that raced visually as "a unit appearing
      // before its own building did". Any other structure (Gold Mine, Tech
      // Lab, Command Post, a combat tower) doesn't produce units, so it's
      // fine to still try capturing/producing from the AI's existing
      // buildings in the same tick.
      final justBuiltProduction =
          justBuilt == BuildingType.trainingCenter ||
          justBuilt == BuildingType.warFactory;
      if (!justBuiltProduction) {
        // Claiming a resource node is a standing economic priority, so
        // it's tried before (and thus gets first refusal on any free War
        // Factory ahead of) a purely-combat production roll.
        _tryCaptureNode(aiTeam);
        _tryProduce(aiTeam);
      }
      // Re-evaluate the previous attack's outcome and retry dispatching
      // whatever's currently staged EVERY decision tick - not just the
      // instant a fresh unit gets staged. Without this, a squad that
      // couldn't find a live target the moment it filled up (e.g. the
      // enemy base was mid-mount, or its only tower target had just been
      // destroyed) would sit staged forever unless another unit happened
      // to be produced later; this is what let the AI's first attack also
      // be its last.
      _evaluateLastAttack(_decisionInterval);
      if (_stagedAttackers.isNotEmpty &&
          _stagedAttackers.length >= _effectiveSquadSize) {
        _dispatchAttackSquad(aiTeam);
      }
    }
  }

  /// The AI's full buildable roster right now (see
  /// `MobileUnitRepositoryImpl.kindsFor`) - not just what it happens to
  /// already own a production building for - so the director (Gemini, via
  /// [SkirmishDirective.preferredUnitKind]) always gets to reason about
  /// every unit kind it could ever choose to build, not a subset. Carries
  /// each kind's real combat profile (domain, damage, range, speed), not
  /// just its name/cost, so the director actually knows how each unit
  /// fights instead of guessing from a label.
  List<UnitRosterEntry> _availableUnitRoster(Team aiTeam) =>
      game.unitRepository.kindsFor(aiTeam).map((kind) {
        final blueprint = game.unitRepository.blueprintFor(aiTeam, kind);
        return UnitRosterEntry(
          kind: kind.name,
          cost: blueprint.cost,
          isVehicle: blueprint.isVehicle,
          attacksAir: blueprint.attackDomains.contains(UnitDomain.air),
          domain: blueprint.domain.name,
          damage: blueprint.attackDamage,
          range: blueprint.attackRange,
          speed: blueprint.speed,
        );
      }).toList();

  /// Every tower/building the AI can ever build, with its own combat
  /// profile - the structure-side counterpart of [_availableUnitRoster], so
  /// the director understands the AI's defensive/economic options (cost,
  /// range, firepower, what domain they can hit) instead of only ever
  /// seeing raw tower counts.
  List<TowerRosterEntry> _availableTowerRoster() =>
      <UnitType>[..._infrastructureBuildOrder, ..._combatTowerTypes].map((
        type,
      ) {
        final blueprint = game.blueprintFor(type);
        return TowerRosterEntry(
          type: type.name,
          cost: blueprint.cost,
          damage: blueprint.damage,
          range: blueprint.range,
          maxHp: blueprint.maxHp,
          attacksAir: blueprint.attackDomains.contains(UnitDomain.air),
          attacksGround: blueprint.attackDomains.contains(UnitDomain.ground),
        );
      }).toList();

  /// A top-down `#`/`.` read of the battlefield grid (blocked terrain or an
  /// occupied cell vs. open ground) - the director's "read the blocks on
  /// the screen" view of the map, letting it reason about chokepoints and
  /// buildable space instead of only raw unit/tower counts. See
  /// [SkirmishSnapshot.terrainRows].
  List<String> _terrainRows() {
    final grid = game.terrainMap.grid;
    return List.generate(grid.rows, (row) {
      final buffer = StringBuffer();
      for (var col = 0; col < grid.cols; col++) {
        buffer.write(grid.isBlocked(col, row) ? '#' : '.');
      }
      return buffer.toString();
    });
  }

  SkirmishSnapshot _buildSnapshot() {
    final economy = game.aiEconomy!;
    final aiTeam = game.aiTeam!;
    final grid = game.terrainMap.grid;
    final aiBaseCell = game.world.aiHomeBase == null
        ? null
        : grid.worldToCell(game.world.aiHomeBase!.position);
    final playerBaseCell = game.world.playerHomeBase == null
        ? null
        : grid.worldToCell(game.world.playerHomeBase!.position);
    return SkirmishSnapshot(
      aiGold: economy.gold,
      aiHealth: economy.health,
      playerGold: game.gameState.gold,
      playerHealth: game.gameState.health,
      aiTowerCount: game.world.activeTowers
          .where((t) => t.owner == aiTeam)
          .length,
      playerTowerCount: game.world.activeTowers
          .where((t) => t.owner == game.playerTeam)
          .length,
      aiUnitCount: game.world.activeUnits
          .where((u) => !u.destroyed && u.team.id == aiTeam.id)
          .length,
      playerUnitCount: game.world.activeUnits
          .where((u) => !u.destroyed && u.team.id == game.playerTeam.id)
          .length,
      availableUnits: _availableUnitRoster(aiTeam),
      availableTowers: _availableTowerRoster(),
      terrainRows: _terrainRows(),
      aiBaseCol: aiBaseCell?.x,
      aiBaseRow: aiBaseCell?.y,
      playerBaseCol: playerBaseCell?.x,
      playerBaseRow: playerBaseCell?.y,
    );
  }

  /// Free, buildable cells in an expanding ring around the AI's base,
  /// nearest-ring-first and shuffled within each ring - keeps its
  /// structures clustered around its own base rather than scattered
  /// anywhere on the map. [BoomspireGame.buildStructure] still does its own
  /// reachability check on whichever candidate is tried, so a cell that
  /// would seal off the base is simply skipped.
  Iterable<Point<int>> _candidateCells(Vector2 basePosition) sync* {
    final grid = game.terrainMap.grid;
    final baseCell = grid.worldToCell(basePosition);
    for (var radius = 2; radius <= 6; radius++) {
      final ring = <Point<int>>[];
      for (var dx = -radius; dx <= radius; dx++) {
        for (var dy = -radius; dy <= radius; dy++) {
          if (dx.abs() != radius && dy.abs() != radius) continue;
          ring.add(Point(baseCell.x + dx, baseCell.y + dy));
        }
      }
      ring.shuffle(_rnd);
      for (final cell in ring) {
        if (!grid.inBounds(cell.x, cell.y)) continue;
        if (grid.isBlocked(cell.x, cell.y)) continue;
        yield cell;
      }
    }
  }

  /// The broad category a unit kind falls into for persona-lean and
  /// combined-arms-diversity purposes (see [_pickKind]) - not the same as
  /// [UnitDomain]: a ground vehicle and a plane are both non-infantry, but
  /// only the plane counts as `air`.
  String _categoryOf(Team aiTeam, UnitKind kind) {
    final blueprint = game.unitRepository.blueprintFor(aiTeam, kind);
    if (blueprint.domain == UnitDomain.air) return 'air';
    if (blueprint.isVehicle) return 'vehicle';
    return 'infantry';
  }

  /// The cheapest unit the AI could ever produce - what it must always
  /// keep in reserve before spending on another building once it already
  /// has a way to produce units, so it never buys itself into a corner
  /// where it owns plenty of buildings but can't actually afford a single
  /// unit out of any of them.
  int _cheapestUnitCost(Team aiTeam) => game.unitRepository
      .kindsFor(aiTeam)
      .map((k) => game.unitRepository.blueprintFor(aiTeam, k).cost)
      .reduce(min);

  /// The domain most worth countering among a set of threats - air takes
  /// priority since ground-only towers can't hit airborne units at all.
  UnitDomain _counterDomainFor(List<MobileUnitComponent> threats) =>
      threats.any((u) => u.blueprint.domain == UnitDomain.air)
      ? UnitDomain.air
      : UnitDomain.ground;

  /// Sends every currently-staged unit at [_resolveAttackTarget] together,
  /// then clears the staging list and records the outcome to evaluate later
  /// (see [_evaluateLastAttack]) - the AI's answer to "how to attack with
  /// what quantity and where". If no live target can be resolved right now
  /// the staged units are simply left in place (still defending themselves,
  /// per [MobileUnitComponent.issueMoveOrder]) and dispatch is retried
  /// automatically on the next decision tick (see [update]).
  void _dispatchAttackSquad(Team aiTeam) {
    final target = _resolveAttackTarget(aiTeam);
    if (target == null) return;
    final dispatched = <MobileUnitComponent>[];
    for (final unit in _stagedAttackers) {
      if (unit.destroyed) continue;
      unit.issueAttackOrder(target);
      dispatched.add(unit);
    }
    _stagedAttackers.clear();
    if (dispatched.isEmpty) return;
    _pendingAttackTarget = target;
    _pendingAttackTargetHealthRatio = target.healthRatio;
    _pendingAttackUnits = dispatched;
    _pendingAttackTimer = _attackEvaluationDelay;
  }

  /// Judges whether the most recently dispatched squad (see
  /// [_dispatchAttackSquad]) actually accomplished anything, [
  /// _attackEvaluationDelay] seconds after it was sent - long enough for it
  /// to have reached and fought at its target. An attack that made no dent
  /// in its target's health *and* got completely wiped out counts as a
  /// failure: [_requiredSquadSize] grows so the next squad the AI rebuilds
  /// is bigger before it tries again ("prepare a stronger strategy after a
  /// failed attack", per the fix this implements). Any real progress
  /// (the target took damage or was destroyed) resets the requirement back
  /// down to the directive's own squad size.
  void _evaluateLastAttack(double elapsed) {
    final target = _pendingAttackTarget;
    if (target == null) return;
    _pendingAttackTimer -= elapsed;
    if (_pendingAttackTimer > 0) return;

    final madeProgress =
        target.destroyed ||
        target.healthRatio < _pendingAttackTargetHealthRatio - 0.02;
    final wiped = _pendingAttackUnits.every((u) => u.destroyed);
    if (wiped && !madeProgress) {
      _requiredSquadSize = min(_requiredSquadSize + 2, _maxRequiredSquadSize);
    } else if (madeProgress) {
      _requiredSquadSize = _directive.squadSize;
    }
    _pendingAttackTarget = null;
    _pendingAttackUnits = const [];
  }

  int _ownedCombatTowerCount(Team aiTeam) => game.world.activeTowers
      .where(
        (t) =>
            t.owner.id == aiTeam.id &&
            _combatTowerTypes.contains(t.blueprint.type),
      )
      .length;

  int _ownedCountOf(Team aiTeam, UnitType type) => game.world.activeTowers
      .where((t) => t.owner.id == aiTeam.id && t.blueprint.type == type)
      .length;

  /// The director's explicit pick (see [SkirmishDirective.preferredUnitKind])
  /// if it named one of [kinds] - otherwise a weighted-random pick among
  /// [kinds]: a kind that can hit air gets extra weight while the player
  /// has aircraft up, the dedicated Anti-Tank soldier gets extra weight
  /// while the player leans on vehicles, this match's persona (see
  /// [_CommanderPersona]) leans the pick toward its favored category, and -
  /// the combined-arms tweak that keeps a persona's lean from becoming a
  /// single-kind army - a category that already dominates the squad
  /// currently staging near base (see [_stagedAttackers]) gets eased off so
  /// a second/third category still gets a look-in. Never a plain random
  /// pick, so variety is always still possible.
  UnitKind _pickKind(
    List<UnitKind> kinds,
    Team aiTeam,
    ({int air, int vehicle, int airTowers, int groundTowers, int builders})
    enemy,
  ) {
    final preferred = _directive.preferredUnitKind;
    if (preferred != null) {
      for (final kind in kinds) {
        if (kind.name == preferred) return kind;
      }
    }

    final staged = _stagedAttackers.where((u) => !u.destroyed).toList();
    final stagedCounts = <String, int>{};
    for (final unit in staged) {
      final category = unit.blueprint.domain == UnitDomain.air
          ? 'air'
          : (unit.blueprint.isVehicle ? 'vehicle' : 'infantry');
      stagedCounts[category] = (stagedCounts[category] ?? 0) + 1;
    }

    final weighted = <UnitKind>[];
    for (final kind in kinds) {
      final blueprint = game.unitRepository.blueprintFor(aiTeam, kind);
      final category = _categoryOf(aiTeam, kind);
      var weight = 1;
      if (enemy.air > 0 && blueprint.attackDomains.contains(UnitDomain.air)) {
        weight += 2;
      }
      if (enemy.vehicle > 0 && kind == UnitKind.antiTankSoldier) weight += 2;
      if (_persona.favoredCategory == category) weight += 2;
      final dominance = staged.isEmpty
          ? 0.0
          : (stagedCounts[category] ?? 0) / staged.length;
      if (staged.length >= 2 && dominance > 0.6) weight = max(1, weight - 1);
      weighted.addAll(List.filled(weight, kind));
    }
    return weighted[_rnd.nextInt(weighted.length)];
  }

  /// A coarse read of what the human player currently has on the field AND
  /// standing - mobile units, combat towers, and production buildings
  /// ("builders") - used to bias which unit kind the AI produces next (see
  /// [_pickKind]) and which combat tower it builds (see
  /// [_strategicCounterDomain]/[_tryBuild]). Recomputed fresh from live
  /// state every decision tick, so the AI's strategy keeps adapting as the
  /// player builds (or loses) any new unit, tower, or production building -
  /// never a one-time snapshot taken only at the start of the match.
  ({int air, int vehicle, int airTowers, int groundTowers, int builders})
  _playerComposition() {
    var air = 0;
    var vehicle = 0;
    for (final unit in game.world.unitsAlliedWith(game.playerTeam)) {
      if (unit.blueprint.domain == UnitDomain.air) air++;
      if (unit.blueprint.isVehicle) vehicle++;
    }
    var airTowers = 0;
    var groundTowers = 0;
    var builders = 0;
    for (final tower in game.world.activeTowers) {
      if (tower.owner.id != game.playerTeam.id || tower.destroyed) continue;
      final type = tower.blueprint.type;
      if (type == BuildingType.trainingCenter ||
          type == BuildingType.warFactory) {
        builders++;
      } else if (tower.blueprint.damage > 0) {
        if (tower.blueprint.attackDomains.contains(UnitDomain.air)) {
          airTowers++;
        } else {
          groundTowers++;
        }
      }
    }
    return (
      air: air,
      vehicle: vehicle,
      airTowers: airTowers,
      groundTowers: groundTowers,
      builders: builders,
    );
  }

  Future<void> _refreshDirective() async {
    _fetchingDirective = true;
    try {
      _directive = await game.aiDirector.planSkirmish(_buildSnapshot());
    } finally {
      _fetchingDirective = false;
    }
  }

  /// Where the current directive wants a completed attack squad sent - the
  /// player's weakest (lowest health-fraction) tower for [AttackTargetKind
  /// .weakestEnemyTower], falling back to the player's base whenever there
  /// are no player towers to focus on, or for [AttackTargetKind.enemyBase]
  /// outright.
  Attackable? _resolveAttackTarget(Team aiTeam) {
    if (_directive.attackTarget == AttackTargetKind.weakestEnemyTower) {
      final playerTowers = game.world.activeTowers
          .where((t) => t.owner.id == game.playerTeam.id && !t.destroyed)
          .toList();
      if (playerTowers.isNotEmpty) {
        playerTowers.sort((a, b) => a.healthRatio.compareTo(b.healthRatio));
        return playerTowers.first;
      }
    }
    return game.enemyHomeBaseFor(aiTeam);
  }

  /// Holds a freshly-produced attack unit in place near base (it still
  /// auto-fights anything that wanders into range, per [MobileUnitComponent
  /// .issueMoveOrder]) instead of letting it immediately beeline off alone,
  /// and dispatches the whole staged squad together the moment it reaches
  /// [_effectiveSquadSize].
  void _stageAttacker(Team aiTeam, MobileUnitComponent unit) {
    unit.issueMoveOrder(unit.position.clone());
    _stagedAttackers.add(unit);
    if (_stagedAttackers.length >= _effectiveSquadSize) {
      _dispatchAttackSquad(aiTeam);
    }
  }

  /// The domain most worth countering given the player's overall fielded
  /// composition (units AND standing towers, see [_playerComposition]) -
  /// used to bias which combat tower the AI builds when nothing is
  /// actively assaulting its base right now (see [_tryBuild]); returns null
  /// when the player has nothing up yet to react to.
  UnitDomain? _strategicCounterDomain(
    ({int air, int vehicle, int airTowers, int groundTowers, int builders})
    enemy,
  ) {
    final airSignal = enemy.air + enemy.airTowers;
    final groundSignal = enemy.vehicle + enemy.groundTowers;
    if (airSignal == 0 && groundSignal == 0) return null;
    return airSignal > groundSignal ? UnitDomain.air : UnitDomain.ground;
  }

  /// Live hostile mobile units within [_threatRadius] of the AI's own base
  /// - an active assault worth reacting to defensively right now.
  List<MobileUnitComponent> _threatsNearBase(
    Team aiTeam,
    Vector2 basePosition,
  ) => game.world
      .unitsHostileTo(aiTeam)
      .where((u) => u.position.distanceTo(basePosition) <= _threatRadius)
      .toList();

  /// Attempts one build this tick, exactly through the same gate the
  /// player's build menu uses ([BoomspireGame.canBuildTower]/
  /// [BoomspireGame.buildStructure]). Priority order: (1) an urgent
  /// domain-countering defense tower whenever the base is under active
  /// threat and below its garrison target (see [_threatsNearBase]) - the
  /// one case that may spend down past the unit reserve, since an assault
  /// in progress is worth reacting to now; (2) infrastructure still
  /// missing/under its [_productionBuildingTargets] cap; (3) a combat
  /// tower - unconditionally while still below the baseline defense
  /// garrison, otherwise only per the directive's `buildBias` coin toss,
  /// biased toward whatever domain the nearest threats need countering.
  /// Before it owns a single Training Center or War Factory, (2) rushes
  /// freely - there's nothing to produce yet anyway, so getting to its
  /// first production building always wins. Once it has one, though,
  /// *every* further purchase in (2)/(3) both must leave enough gold to
  /// still afford its cheapest unit afterward (see [_cheapestUnitCost])
  /// and is itself only attempted per the same `buildBias` coin toss as
  /// combat towers - so "build more infrastructure" stops being an
  /// automatic priority over "produce units" and instead becomes just
  /// another strategic option the directive weighs, same as everything
  /// else. Returns the type actually placed, or null if nothing was built
  /// this tick.
  UnitType? _tryBuild(Team aiTeam) {
    final base = game.world.aiHomeBase;
    if (base == null || !base.isMounted) return null;
    final ownStructureCount = game.world.activeTowers
        .where((t) => t.owner.id == aiTeam.id)
        .length;
    if (ownStructureCount >= _maxOwnStructures) return null;

    final hasProduction =
        _ownedCountOf(aiTeam, BuildingType.trainingCenter) > 0 ||
        _ownedCountOf(aiTeam, BuildingType.warFactory) > 0;
    final unitReserve = hasProduction ? _cheapestUnitCost(aiTeam) : 0;
    final enemy = _playerComposition();

    final threats = _threatsNearBase(aiTeam, base.position);
    final defenseTowerCount = _ownedCombatTowerCount(aiTeam);
    // The garrison floor rises not just when units are actively approaching
    // right now, but also when the player is fielding more production
    // buildings ("builders") than the AI has combat towers to answer with -
    // a standing signal that a bigger assault is being prepared, worth
    // getting ahead of instead of only reacting once units are already at
    // the door.
    final defenseTarget =
        _baseDefenseTowerTarget +
        (threats.isNotEmpty ? 2 : 0) +
        (enemy.builders > defenseTowerCount ? 1 : 0);
    final needsDefense = defenseTowerCount < defenseTarget;
    final isUrgentDefense = needsDefense && threats.isNotEmpty;
    final skipMoreInfraForNow =
        hasProduction &&
        !isUrgentDefense &&
        _rnd.nextDouble() > _directive.buildBias + 0.2;

    UnitType? type;
    if (!isUrgentDefense && !skipMoreInfraForNow) {
      for (final candidate in _infrastructureOrder) {
        final target = _productionBuildingTargets[candidate];
        if (target != null && _ownedCountOf(aiTeam, candidate) >= target) {
          continue;
        }
        if (!game.canBuildTower(candidate, owner: aiTeam)) continue;
        final cost = game.blueprintFor(candidate).cost;
        if (game.goldFor(aiTeam) - cost < unitReserve) continue;
        type = candidate;
        break;
      }
    }

    if (type == null) {
      // Below the defense floor, a counter tower is never optional; beyond
      // it, a combat tower is only built per the directive's buildBias so
      // the AI doesn't sink every spare coin into towers over units.
      if (!needsDefense && _rnd.nextDouble() > _directive.buildBias + 0.2) {
        return null;
      }
      final reserve = isUrgentDefense ? 0 : unitReserve;
      final options = _combatTowerTypes
          .where(
            (t) =>
                game.canBuildTower(t, owner: aiTeam) &&
                game.goldFor(aiTeam) - game.blueprintFor(t).cost >= reserve,
          )
          .toList();
      if (options.isEmpty) return null;
      if (threats.isNotEmpty) {
        final counterDomain = _counterDomainFor(threats);
        final countering = options
            .where(
              (t) => game.blueprintFor(t).attackDomains.contains(counterDomain),
            )
            .toList();
        if (countering.isNotEmpty) {
          type = countering[_rnd.nextInt(countering.length)];
        }
      } else {
        // No unit is actually at the gate right now, but the player's
        // overall fielded composition (units and standing towers alike)
        // still points at what will matter next time one is - lean toward
        // building that counter instead of a flat coin toss, so the AI's
        // tower choices keep adapting to the player's build-out, not just
        // to an active raid.
        final strategicDomain = _strategicCounterDomain(enemy);
        if (strategicDomain != null) {
          final countering = options
              .where(
                (t) => game
                    .blueprintFor(t)
                    .attackDomains
                    .contains(strategicDomain),
              )
              .toList();
          if (countering.isNotEmpty && _rnd.nextDouble() < 0.7) {
            type = countering[_rnd.nextInt(countering.length)];
          }
        }
      }
      type ??= options[_rnd.nextInt(options.length)];
    }

    for (final cell in _candidateCells(base.position).take(24)) {
      final point = game.terrainMap.grid.cellCenter(cell);
      if (game.buildStructure(aiTeam, type, point) != null) return type;
    }
    return null;
  }

  /// Sends an owned ground vehicle to go claim a resource node the AI
  /// doesn't already own - the same `ResourceNodeComponent` economy feature
  /// the player can use, so the AI's income isn't limited to its base
  /// buildings alone. Skips a node it's already sent a capturer toward so
  /// it doesn't spam its whole War Factory queue at one node, and never
  /// steals a vehicle destined for combat (it only ever produces an extra
  /// one for this purpose, through the same gold-gated
  /// [WarFactoryComponent.produceUnit] the player's build menu uses).
  void _tryCaptureNode(Team aiTeam) {
    final nodes = game.world.activeResourceNodes.where(
      (n) => n.owner?.id != aiTeam.id,
    );
    if (nodes.isEmpty) return;

    final capturersEnRoute = game.world.activeUnits.where(
      (u) =>
          !u.destroyed &&
          u.team.id == aiTeam.id &&
          u.objective == UnitObjective.captureNode,
    );

    for (final node in nodes) {
      final alreadyClaiming = capturersEnRoute.any(
        (u) => u.captureTarget != null && u.captureTarget == node.position,
      );
      if (alreadyClaiming) continue;

      for (final tower in game.world.activeTowers) {
        if (tower.owner.id != aiTeam.id) continue;
        if (tower is! WarFactoryComponent || !tower.canProduce) continue;
        final kinds = game.unitRepository.kindsFor(aiTeam).where((k) {
          final blueprint = game.unitRepository.blueprintFor(aiTeam, k);
          return blueprint.isVehicle &&
              blueprint.cost <= game.goldFor(aiTeam) &&
              game.canProduceUnit(k, owner: aiTeam);
        }).toList();
        if (kinds.isEmpty) continue;
        final produced = tower.produceUnit(
          kinds[_rnd.nextInt(kinds.length)],
          objective: UnitObjective.captureNode,
          captureTarget: node.position.clone(),
        );
        if (produced) return;
      }
    }
  }

  /// Mans whichever production buildings the AI has already built - it
  /// cannot produce anything at all until it has built a Training
  /// Center/War Factory of its own, same as the player. Always tries to
  /// produce when it can afford to (no RNG skip) so gold reliably turns
  /// into units instead of piling up toward the next building purchase.
  /// Which kind gets produced prefers the director's explicit
  /// [SkirmishDirective.preferredUnitKind] pick, falling back to whatever
  /// currently counters the human player's own fielded army (see
  /// [_playerComposition]/[_pickKind]) instead of a flat random choice, so
  /// the AI's attacks actually adapt to what it's fighting. Every unit
  /// produced this way is held back near base (see [_stageAttacker]) until
  /// [SkirmishDirective.squadSize] of them are ready to push out together.
  void _tryProduce(Team aiTeam) {
    _stagedAttackers.removeWhere((u) => u.destroyed);
    final enemy = _playerComposition();
    for (final tower in game.world.activeTowers) {
      if (tower.owner.id != aiTeam.id) continue;
      if (tower is TrainingCenterComponent && tower.canProduce) {
        final kinds = TrainingCenterComponent.producibleKinds
            .where((k) => tower.costFor(k) <= game.goldFor(aiTeam))
            .toList();
        if (kinds.isNotEmpty &&
            tower.produceUnit(_pickKind(kinds, aiTeam, enemy))) {
          _stageAttacker(aiTeam, game.world.activeUnits.last);
        }
      } else if (tower is WarFactoryComponent && tower.canProduce) {
        final kinds = game.unitRepository
            .kindsFor(aiTeam)
            .where((k) => !TrainingCenterComponent.producibleKinds.contains(k))
            .where((k) => tower.costFor(k) <= game.goldFor(aiTeam))
            .where((k) => game.canProduceUnit(k, owner: aiTeam))
            .toList();
        if (kinds.isNotEmpty &&
            tower.produceUnit(_pickKind(kinds, aiTeam, enemy))) {
          _stageAttacker(aiTeam, game.world.activeUnits.last);
        }
      }
    }
  }
}

/// The AI opponent's "brain" in a [GameMode.skirmish] match: periodically
/// asks [BoomspireGame.aiDirector] (Gemini, with a deterministic local
/// fallback - see [SkirmishDirective.fallback]) how aggressive to be right
/// now, then spends its own `AiEconomy` wallet through the exact same
/// [BoomspireGame.buildStructure]/[BoomspireGame.canBuildTower] rules the
/// human player's build menu uses - same gold costs, same per-type limits,
/// same Tech Lab/Command Post prerequisite chains, same "never seal the
/// only path between the two bases" guard.
///
/// Four cooperating strategies, evaluated every [_decisionInterval]:
/// - **Economy**: Gold Mine + resource-node capture (see [_tryCaptureNode])
///   fund everything else; a bounded number of Training Centers/War
///   Factories (see [_productionBuildingTargets]) are built for production
///   capacity instead of endlessly re-building more of them, and - once it
///   has at least one of those - every further building purchase must
///   leave enough gold to still afford its cheapest unit afterward (see
///   [_cheapestUnitCost]), so it never buries its whole wallet in
///   buildings and finds itself unable to actually field a unit.
/// - **Defense**: a baseline garrison of combat towers (see
///   [_baseDefenseTowerTarget]) is kept around its own base at all times,
///   reinforced with a domain-appropriate counter tower (e.g. anti-air vs.
///   an air raid) whenever hostile units are actually approaching (see
///   [_threatRadius]) - the one purchase allowed to dip below the unit
///   reserve, since an assault in progress is worth reacting to now.
/// - **Production/attack**: once it has a Training Center/War Factory, it
///   mans them every tick it can afford to (see [_tryProduce]), biasing
///   which unit kind it rolls out toward whatever currently counters the
///   human player's own fielded army (see [_playerComposition]) - e.g. more
///   anti-air once the player has aircraft up.
/// - **Directive**: [SkirmishDirective.aggression]/`buildBias` (Gemini or
///   the local fallback) tunes the overall balance between "more attack
///   units" vs. "more extra towers" beyond the above floors, reacting to
///   both tower count *and* fielded-unit-count disparity against the
///   player (see [SkirmishSnapshot.aiUnitCount]/`playerUnitCount`).
///
/// It builds its own Training Center/War Factory before it can produce any
/// units at all (just like the player has to), and only ever mans those
/// buildings to actually roll units out - there is no direct "spawn a unit
/// from the base" shortcut anymore. Its only edge over a literal 1:1
/// player clone is a generous total-structure soft cap (see
/// [_maxOwnStructures]) that exists purely to bound an AI that never gets
/// tired of building, not because it's allowed to build less.

/// A specialized long-term identity the AI opponent commits to for the
/// whole match, chosen once at [AiSkirmishControllerComponent] construction
/// - the AI's answer to C&C Generals' distinct specialized generals
/// (armor/infantry/air), layered *underneath* the per-tick
/// [SkirmishDirective] (Gemini or its local fallback): the persona biases
/// which production building it rushes first and which unit category it
/// leans toward producing, while the directive still tunes moment-to-moment
/// aggression/targeting on top. This is what makes the AI "hybrid" - a
/// stable scripted specialization combined with a reactive tactical layer,
/// instead of either alone.
enum _CommanderPersona {
  /// Rushes the War Factory first and leans on vehicles/aircraft.
  armored,

  /// Rushes the Training Center first and leans on cheap infantry numbers.
  infantry,

  /// Rushes the War Factory first and leans hardest on aircraft.
  airborne,

  /// No particular lean - the original all-around behavior.
  balanced;

  /// The broad unit category this persona favors producing - `null` for
  /// [balanced], which applies no extra weighting in [_pickKind].
  String? get favoredCategory => switch (this) {
    _CommanderPersona.armored => 'vehicle',
    _CommanderPersona.infantry => 'infantry',
    _CommanderPersona.airborne => 'air',
    _CommanderPersona.balanced => null,
  };

  /// Whether this persona wants the War Factory built ahead of the
  /// Training Center in [AiSkirmishControllerComponent._infrastructureOrder]
  /// - both [armored] (vehicles) and [airborne] (aircraft) only come out of
  /// a War Factory, so both rush it first; [infantry]/[balanced] keep the
  /// default Training-Center-first order.
  bool get rushesWarFactory =>
      this == _CommanderPersona.armored || this == _CommanderPersona.airborne;
}
