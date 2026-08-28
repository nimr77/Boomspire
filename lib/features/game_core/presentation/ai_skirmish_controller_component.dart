import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';

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
  /// last since those only unlock optional extra towers.
  static const _infrastructureBuildOrder = [
    BuildingType.goldMine,
    BuildingType.trainingCenter,
    BuildingType.warFactory,
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

  double _directiveTimer = _directiveInterval * 0.2;
  double _decisionTimer = _decisionInterval * 0.5;
  bool _fetchingDirective = false;
  SkirmishDirective _directive = const SkirmishDirective(
    aggression: 0.35,
    buildBias: 0.5,
  );

  final Random _rnd = Random();

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
    }
  }

  SkirmishSnapshot _buildSnapshot() {
    final economy = game.aiEconomy!;
    final aiTeam = game.aiTeam!;
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

  /// The domain most worth countering among a set of threats - air takes
  /// priority since ground-only towers can't hit airborne units at all.
  UnitDomain _counterDomainFor(List<MobileUnitComponent> threats) =>
      threats.any((u) => u.blueprint.domain == UnitDomain.air)
      ? UnitDomain.air
      : UnitDomain.ground;

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

  /// The cheapest unit the AI could ever produce - what it must always
  /// keep in reserve before spending on another building once it already
  /// has a way to produce units, so it never buys itself into a corner
  /// where it owns plenty of buildings but can't actually afford a single
  /// unit out of any of them.
  int _cheapestUnitCost(Team aiTeam) => game.unitRepository
      .kindsFor(aiTeam)
      .map((k) => game.unitRepository.blueprintFor(aiTeam, k).cost)
      .reduce(min);

  /// Weighted-random pick among [kinds]: a kind that can hit air gets extra
  /// weight while the player has aircraft up, and the dedicated Anti-Tank
  /// soldier gets extra weight while the player leans on vehicles - a plain
  /// random pick otherwise, so this never fully locks out variety.
  UnitKind _pickKind(
    List<UnitKind> kinds,
    Team aiTeam,
    ({int air, int vehicle}) enemy,
  ) {
    final weighted = <UnitKind>[];
    for (final kind in kinds) {
      final blueprint = game.unitRepository.blueprintFor(aiTeam, kind);
      var weight = 1;
      if (enemy.air > 0 && blueprint.attackDomains.contains(UnitDomain.air)) {
        weight += 2;
      }
      if (enemy.vehicle > 0 && kind == UnitKind.antiTankSoldier) weight += 2;
      weighted.addAll(List.filled(weight, kind));
    }
    return weighted[_rnd.nextInt(weighted.length)];
  }

  /// A coarse read of what the human player currently has on the field,
  /// used to bias which unit kind the AI produces next.
  ({int air, int vehicle}) _playerComposition() {
    var air = 0;
    var vehicle = 0;
    for (final unit in game.world.unitsAlliedWith(game.playerTeam)) {
      if (unit.blueprint.domain == UnitDomain.air) air++;
      if (unit.blueprint.isVehicle) vehicle++;
    }
    return (air: air, vehicle: vehicle);
  }

  Future<void> _refreshDirective() async {
    _fetchingDirective = true;
    try {
      _directive = await game.aiDirector.planSkirmish(_buildSnapshot());
    } finally {
      _fetchingDirective = false;
    }
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

    final threats = _threatsNearBase(aiTeam, base.position);
    final defenseTowerCount = _ownedCombatTowerCount(aiTeam);
    final defenseTarget =
        _baseDefenseTowerTarget + (threats.isNotEmpty ? 2 : 0);
    final needsDefense = defenseTowerCount < defenseTarget;
    final isUrgentDefense = needsDefense && threats.isNotEmpty;
    final skipMoreInfraForNow =
        hasProduction &&
        !isUrgentDefense &&
        _rnd.nextDouble() > _directive.buildBias + 0.2;

    UnitType? type;
    if (!isUrgentDefense && !skipMoreInfraForNow) {
      for (final candidate in _infrastructureBuildOrder) {
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
          return blueprint.isVehicle && blueprint.cost <= game.goldFor(aiTeam);
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
  /// Which kind gets produced is weighted toward whatever currently
  /// counters the human player's own fielded army (see
  /// [_playerComposition]/[_pickKind]) instead of a flat random choice, so
  /// the AI's attacks actually adapt to what it's fighting.
  void _tryProduce(Team aiTeam) {
    final enemy = _playerComposition();
    for (final tower in game.world.activeTowers) {
      if (tower.owner.id != aiTeam.id) continue;
      if (tower is TrainingCenterComponent && tower.canProduce) {
        final kinds = TrainingCenterComponent.producibleKinds
            .where((k) => tower.costFor(k) <= game.goldFor(aiTeam))
            .toList();
        if (kinds.isNotEmpty) {
          tower.produceUnit(_pickKind(kinds, aiTeam, enemy));
        }
      } else if (tower is WarFactoryComponent && tower.canProduce) {
        final kinds = game.unitRepository
            .kindsFor(aiTeam)
            .where((k) => !TrainingCenterComponent.producibleKinds.contains(k))
            .where((k) => tower.costFor(k) <= game.goldFor(aiTeam))
            .toList();
        if (kinds.isNotEmpty) {
          tower.produceUnit(_pickKind(kinds, aiTeam, enemy));
        }
      }
    }
  }
}
