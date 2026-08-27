import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';

import '../../../core/combat/unit_objective.dart';
import '../../ai_director/domain/models/skirmish_directive.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../towers/domain/models/tower_type.dart';
import '../domain/models/game_status.dart';
import 'boomspire_game.dart';

/// The AI opponent's "brain" in a [GameMode.skirmish] match: earns passive
/// income, periodically asks [BoomspireGame.aiDirector] (Gemini, with a
/// deterministic local fallback - see [SkirmishDirective.fallback]) how
/// aggressive to be right now, then spends its own [AiEconomy] wallet on
/// defensive towers around its base and attack units that march to
/// assault the player's base ([UnitObjective.assaultBase]).
///
/// Deliberately simpler than the player's build menu: it only ever builds
/// from a small set of towers that need no prerequisite unlocks (no Tech
/// Lab/Command Post chains to reason about) and produces units directly
/// from its base rather than through a Training Center/War Factory.
class AiSkirmishControllerComponent extends Component
    with HasGameReference<BoomspireGame> {
  static const _incomeInterval = 4.0;
  static const _incomeAmount = 40;
  static const _directiveInterval = 14.0;
  static const _buildInterval = 6.0;
  static const _produceInterval = 5.0;
  static const _maxOwnTowers = 8;

  static const _buildableTypes = [
    TowerType.machineGun,
    TowerType.rocket,
    TowerType.cannon,
    TowerType.antiAir,
  ];

  double _incomeTimer = 0;
  double _directiveTimer = _directiveInterval * 0.2;
  double _buildTimer = _buildInterval * 0.5;
  double _produceTimer = _produceInterval * 0.6;
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

    _incomeTimer += dt;
    if (_incomeTimer >= _incomeInterval) {
      _incomeTimer -= _incomeInterval;
      economy.addGold(_incomeAmount);
    }

    _directiveTimer += dt;
    if (_directiveTimer >= _directiveInterval && !_fetchingDirective) {
      _directiveTimer = 0;
      unawaited(_refreshDirective());
    }

    _buildTimer += dt;
    if (_buildTimer >= _buildInterval) {
      _buildTimer = 0;
      _tryBuildTower();
    }

    _produceTimer += dt;
    if (_produceTimer >= _produceInterval) {
      _produceTimer = 0;
      _tryProduceUnit();
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

  /// Looks for a free, buildable cell in an expanding ring around the AI's
  /// base - keeps its towers clustered around its own base rather than
  /// scattered anywhere on the map.
  Point<int>? _findBuildCell(Vector2 basePosition) {
    final grid = game.terrainMap.grid;
    final baseCell = grid.worldToCell(basePosition);
    for (var radius = 2; radius <= 6; radius++) {
      final candidates = <Point<int>>[];
      for (var dx = -radius; dx <= radius; dx++) {
        for (var dy = -radius; dy <= radius; dy++) {
          if (dx.abs() != radius && dy.abs() != radius) continue;
          candidates.add(Point(baseCell.x + dx, baseCell.y + dy));
        }
      }
      candidates.shuffle(_rnd);
      for (final cell in candidates) {
        if (!grid.inBounds(cell.x, cell.y)) continue;
        if (grid.isBlocked(cell.x, cell.y)) continue;
        return cell;
      }
    }
    return null;
  }

  Future<void> _refreshDirective() async {
    _fetchingDirective = true;
    try {
      _directive = await game.aiDirector.planSkirmish(_buildSnapshot());
    } finally {
      _fetchingDirective = false;
    }
  }

  void _tryBuildTower() {
    final economy = game.aiEconomy!;
    final aiTeam = game.aiTeam!;
    final base = game.world.aiHomeBase;
    if (base == null || !base.isMounted) return;

    final ownTowers = game.world.activeTowers
        .where((t) => t.owner == aiTeam)
        .length;
    if (ownTowers >= _maxOwnTowers) return;

    // Higher `buildBias` = more likely to spend this tick on defense rather
    // than saving gold for attack units.
    if (_rnd.nextDouble() > _directive.buildBias + 0.2) return;

    final type = _buildableTypes[_rnd.nextInt(_buildableTypes.length)];
    final blueprint = game.towerRepository.blueprintFor(type);
    if (economy.gold < blueprint.cost) return;

    final cell = _findBuildCell(base.position);
    if (cell == null) return;

    final grid = game.terrainMap.grid;
    grid.setTowerOccupied(cell.x, cell.y, true);

    // Mirrors `BoomspireGame._buildTower`'s "never seal the path" guard -
    // the AI could in theory wall off its own base's only approach just
    // as easily as the player could wall off the AI's.
    final spawnCells = game.terrainMap.spawnPoints
        .map((sp) => grid.worldToCell(Vector2(sp.x, sp.y)))
        .toSet();
    final playerBaseCell = grid.worldToCell(
      Vector2(game.terrainMap.basePoint.x, game.terrainMap.basePoint.y),
    );
    if (!spawnCells.every((sc) => grid.isReachable(sc, playerBaseCell))) {
      grid.setTowerOccupied(cell.x, cell.y, false);
      return;
    }
    if (!economy.spendGold(blueprint.cost)) {
      grid.setTowerOccupied(cell.x, cell.y, false);
      return;
    }

    final tower = game.createTower(
      type,
      grid.cellCenter(cell),
      grid.cellSize,
      blueprint,
      owner: aiTeam,
    );
    game.world.spawnTower(tower);
  }

  void _tryProduceUnit() {
    final economy = game.aiEconomy!;
    final aiTeam = game.aiTeam!;
    final base = game.world.aiHomeBase;
    if (base == null || !base.isMounted) return;

    final kinds = game.unitRepository.kindsFor(aiTeam);
    if (kinds.isEmpty) return;
    final affordable = kinds
        .where(
          (k) =>
              game.unitRepository.blueprintFor(aiTeam, k).cost <= economy.gold,
        )
        .toList();
    if (affordable.isEmpty) return;

    // Higher `aggression` = more likely to spend this tick mustering an
    // attack unit rather than banking gold.
    if (_rnd.nextDouble() > 0.3 + _directive.aggression * 0.55) return;

    final kind = affordable[_rnd.nextInt(affordable.length)];
    final blueprint = game.unitRepository.blueprintFor(aiTeam, kind);
    if (!economy.spendGold(blueprint.cost)) return;

    game.world.spawnUnit(
      MobileUnitComponent(
        blueprint: blueprint,
        position: base.position.clone(),
        team: aiTeam,
        objective: UnitObjective.assaultBase,
      ),
    );
  }
}
