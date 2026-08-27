import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';

import '../../../core/combat/team.dart';
import '../../../core/combat/unit_kind.dart';
import '../../../core/combat/unit_objective.dart';
import '../../ai_director/domain/models/skirmish_directive.dart';
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

  Future<void> _refreshDirective() async {
    _fetchingDirective = true;
    try {
      _directive = await game.aiDirector.planSkirmish(_buildSnapshot());
    } finally {
      _fetchingDirective = false;
    }
  }

  /// Attempts one build this tick, exactly through the same gate the
  /// player's build menu uses ([BoomspireGame.canBuildTower]/
  /// [BoomspireGame.buildStructure]) - infrastructure (Gold Mine, Training
  /// Center, War Factory, Tech Lab, Command Post) is preferred while any of
  /// it is still missing and affordable; otherwise a random unlocked combat
  /// tower is tried, gated by the directive's `buildBias`. Returns the type
  /// actually placed, or null if nothing was built this tick.
  UnitType? _tryBuild(Team aiTeam) {
    final base = game.world.aiHomeBase;
    if (base == null || !base.isMounted) return null;
    final ownStructureCount = game.world.activeTowers
        .where((t) => t.owner.id == aiTeam.id)
        .length;
    if (ownStructureCount >= _maxOwnStructures) return null;

    UnitType? type;
    for (final candidate in _infrastructureBuildOrder) {
      if (!game.canBuildTower(candidate, owner: aiTeam)) continue;
      if (game.goldFor(aiTeam) < game.blueprintFor(candidate).cost) continue;
      type = candidate;
      break;
    }

    if (type == null) {
      // No affordable/unlocked infrastructure left to build right now -
      // fall back to a random unlocked combat tower, gated by buildBias so
      // the AI doesn't sink every spare coin into defense.
      if (_rnd.nextDouble() > _directive.buildBias + 0.2) return null;
      final options = _combatTowerTypes
          .where(
            (t) =>
                game.canBuildTower(t, owner: aiTeam) &&
                game.goldFor(aiTeam) >= game.blueprintFor(t).cost,
          )
          .toList();
      if (options.isEmpty) return null;
      type = options[_rnd.nextInt(options.length)];
    }

    for (final cell in _candidateCells(base.position).take(24)) {
      final point = game.terrainMap.grid.cellCenter(cell);
      if (game.buildStructure(aiTeam, type, point) != null) return type;
    }
    return null;
  }

  /// Mans whichever production buildings the AI has already built - it
  /// cannot produce anything at all until it has built a Training
  /// Center/War Factory of its own, same as the player.
  void _tryProduce(Team aiTeam) {
    if (_rnd.nextDouble() > 0.25 + _directive.aggression * 0.6) return;
    for (final tower in game.world.activeTowers) {
      if (tower.owner.id != aiTeam.id) continue;
      if (tower is TrainingCenterComponent && tower.canProduce) {
        tower.produceSoldier();
      } else if (tower is WarFactoryComponent && tower.canProduce) {
        final kinds = game.unitRepository
            .kindsFor(aiTeam)
            .where((k) => k != UnitKind.soldier)
            .where((k) => tower.costFor(k) <= game.goldFor(aiTeam))
            .toList();
        if (kinds.isNotEmpty) {
          tower.produceUnit(kinds[_rnd.nextInt(kinds.length)]);
        }
      }
    }
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
        final kinds = game.unitRepository
            .kindsFor(aiTeam)
            .where((k) {
              final blueprint = game.unitRepository.blueprintFor(aiTeam, k);
              return blueprint.isVehicle &&
                  blueprint.cost <= game.goldFor(aiTeam);
            })
            .toList();
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
}
