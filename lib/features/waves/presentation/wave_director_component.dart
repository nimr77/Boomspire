import 'dart:async';

import 'package:flame/components.dart';

import '../../../core/combat/team.dart';
import '../../../core/combat/unit_kind.dart';
import '../../../core/combat/unit_objective.dart';
import '../../ai_director/domain/models/battlefield_snapshot.dart';
import '../../ai_director/domain/models/strategy_directive.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../combat/presentation/mobile_unit_component.dart';
import '../../game_core/domain/models/game_status.dart';
import '../../game_core/presentation/boomspire_game.dart';
import '../../terrain/domain/models/terrain_map.dart';

/// Drives round progression: schedules enemy spawns for the current wave,
/// detects when a wave is cleared, and hands out the wave-clear gold bonus
/// or ends the run in victory once the final wave falls. Also consults the
/// AI director (Gemini, with a local fallback) once per wave to decide how
/// hard/what shape the *next* wave should be, and what enemies should
/// prioritize attacking.
class WaveDirectorComponent extends Component
    with HasGameReference<BoomspireGame> {
  /// Above this many total enemies in a wave, the AI director fans the
  /// wave out across more than one entry point instead of committing it
  /// all to a single approach - see [_planSpawnQueue].
  static const _splitThreshold = 15;

  /// A single entry point won't spawn a new unit while this many invaders
  /// it already produced are still loitering nearby - see
  /// [_spawnPointCrowded]. Keeps a wave from stacking a wall of units on
  /// top of one entry point instead of them pushing on toward the base.
  static const _maxUnitsPerSpawnPoint = 12;

  /// How far (in grid cells) a spawned unit has to have moved away from
  /// its entry point before that point is considered clear again.
  static const _spawnClearCells = 5;

  /// How long a batch waits before re-checking a crowded entry point.
  static const _spawnRetryDelay = 0.5;

  /// Entry points closer than this many grid cells to the player's home
  /// base are excluded from spawn selection - see [_planSpawnQueue].
  static const _minHomeDistanceCells = 10;

  int _nextWaveNumber = 1;
  bool _waveActive = false;
  double _preWaveTimer = 3;
  final List<_ScheduledSpawn> _queue = [];
  StrategyDirective? _directive;

  @override
  Future<void> onLoad() async {
    unawaited(_planNextWave(1));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState.status != GameStatus.playing) return;

    if (!_waveActive) {
      _preWaveTimer -= dt;
      if (_preWaveTimer <= 0) _beginWave(_nextWaveNumber);
      return;
    }

    for (final scheduled in List.of(_queue)) {
      scheduled.timer -= dt;
      if (scheduled.timer <= 0) {
        if (_spawnPointCrowded(scheduled.spawnPoint)) {
          // Entry point is full - hold this batch and retry shortly
          // rather than dropping or force-spawning the unit.
          scheduled.timer = _spawnRetryDelay;
          continue;
        }
        game.world.spawnUnit(
          _createEnemy(scheduled.type, scheduled.spawnPoint),
        );
        scheduled.remaining--;
        scheduled.timer = scheduled.interval;
        if (scheduled.remaining <= 0) _queue.remove(scheduled);
      }
    }

    if (_queue.isEmpty && game.world.unitsHostileTo(game.playerTeam).isEmpty) {
      _finishWave();
    }
  }

  void _beginWave(int waveNumber) {
    final def = game.waveRepository.waveDefinition(waveNumber);
    final directive = _directive ?? StrategyDirective.fallback(waveNumber);
    // Each scene can add its own opening-strategy pressure on top of
    // whatever the AI director (or its fallback) computed.
    final aggression = (directive.aggression + game.scene.aggressionBias).clamp(
      0.0,
      1.0,
    );
    game.gameState.setWave(
      waveNumber,
      totalWaves: game.waveRepository.totalWaves,
    );
    game.enemyFocusHint = directive.focusHint;
    game.commanderNote.value = directive.commanderNote;
    game.audioRepository.play(SfxType.waveStart, volume: 0.7);
    final scaledEntries = def.spawns.map((e) {
      final bias = directive.compositionBias[e.type.name] ?? 1.0;
      final scaledCount = (e.count * (1 + aggression * 0.35) * bias)
          .round()
          .clamp(1, 60);
      return _ScaledSpawnEntry(
        type: e.type,
        count: scaledCount,
        interval: e.interval / (1 + aggression * 0.2),
        startDelay: e.startDelay,
      );
    }).toList();
    _queue
      ..clear()
      ..addAll(_planSpawnQueue(scaledEntries, aggression));
    _waveActive = true;
    // Kick off planning for the wave after next while this one plays out, so
    // the Gemini call (if reachable) has the whole wave to complete.
    unawaited(_planNextWave(waveNumber + 1));
  }

  MobileUnitComponent _createEnemy(UnitKind type, Vector2 spawnPoint) {
    final blueprint = game.unitRepository.blueprintFor(Team.invaders, type);
    return MobileUnitComponent(
      blueprint: blueprint,
      team: Team.invaders,
      objective: UnitObjective.rushBase,
      spawnOverride: spawnPoint,
    );
  }

  /// Entry points at least [_minHomeDistanceCells] cells from the player's
  /// home base - keeps the AI from ever spawning right on top of the base
  /// it's supposed to be rushing. Falls back to every entry point if the
  /// home base isn't up yet or none clear the distance (small maps).
  List<PathPoint> _eligibleSpawnPoints() {
    final home = game.world.playerHomeBase?.position;
    final allPoints = List.of(game.terrainMap.spawnPoints);
    if (home == null) return allPoints;
    final minDistance = game.terrainMap.grid.cellSize * _minHomeDistanceCells;
    final far = allPoints.where((p) {
      return Vector2(p.x, p.y).distanceTo(home) >= minDistance;
    }).toList();
    return far.isEmpty ? allPoints : far;
  }

  void _finishWave() {
    _waveActive = false;
    final cleared = game.gameState.currentWave;
    game.gameState.addGold(20 + cleared * 5);

    if (cleared >= game.waveRepository.totalWaves) {
      game.gameState.setStatus(GameStatus.victory);
      game.audioRepository.play(SfxType.victory);
    } else {
      _nextWaveNumber = cleared + 1;
      _preWaveTimer = 6;
    }
  }

  Future<void> _planNextWave(int waveNumber) async {
    final towersByType = <String, List<double>>{};
    for (final tower in game.world.activeTowers) {
      towersByType
          .putIfAbsent(tower.blueprint.type.name, () => [])
          .add(tower.hp / tower.maxHp);
    }
    final snapshot = BattlefieldSnapshot(
      waveNumber: waveNumber,
      totalWaves: game.waveRepository.totalWaves,
      playerHealth: game.gameState.health,
      playerGold: game.gameState.gold,
      towerSummaries: towersByType.entries
          .map(
            (e) => TowerSummary(
              type: e.key,
              count: e.value.length,
              avgHpRatio: e.value.reduce((a, b) => a + b) / e.value.length,
            ),
          )
          .toList(),
    );
    _directive = await game.aiDirector.planNextWave(snapshot);
  }

  /// The AI director's entry-point decision for the wave: where the
  /// enemies come from and how many land at each entry, chosen all at
  /// once rather than letting every unit pick its own spawn independently.
  /// Entry points always come from [BoomspireGame.terrainMap]'s
  /// `spawnPoints` - a perimeter of edges/corners around the base, never
  /// the center. A wave with [_splitThreshold] enemies or fewer still
  /// commits to a single (freshly-chosen) entry point; above that, the
  /// wave is fanned out across multiple entry points at once, scaling
  /// with both the wave's size and its aggression - a big wave under high
  /// aggression can hit from most/every open approach simultaneously.
  List<_ScheduledSpawn> _planSpawnQueue(
    List<_ScaledSpawnEntry> entries,
    double aggression,
  ) {
    final totalEnemies = entries.fold<int>(0, (sum, e) => sum + e.count);
    final availablePoints = _eligibleSpawnPoints()..shuffle();
    final desiredGroups = totalEnemies > _splitThreshold
        ? 2 +
              (aggression * 2).round() +
              ((totalEnemies - _splitThreshold) / 15).ceil()
        : 1;
    final groupCount = desiredGroups.clamp(1, availablePoints.length);
    final groupPoints = availablePoints.take(groupCount).toList();

    final queue = <_ScheduledSpawn>[];
    for (final entry in entries) {
      final perGroup = entry.count ~/ groupCount;
      var remainder = entry.count % groupCount;
      for (var i = 0; i < groupCount; i++) {
        var count = perGroup;
        if (remainder > 0) {
          count++;
          remainder--;
        }
        if (count <= 0) continue;
        final point = groupPoints[i];
        queue.add(
          _ScheduledSpawn(
            type: entry.type,
            remaining: count,
            interval: entry.interval,
            // Slight per-group offset so simultaneous entry points don't
            // all pop their first unit on the exact same frame.
            timer: entry.startDelay + i * 0.4,
            spawnPoint: Vector2(point.x, point.y),
          ),
        );
      }
    }
    return queue;
  }

  /// True once [_maxUnitsPerSpawnPoint] invaders spawned from this run are
  /// still within [_spawnClearCells] cells of [point] - i.e. the entry
  /// point hasn't cleared out enough for another unit to appear there.
  bool _spawnPointCrowded(Vector2 point) {
    final clearRadius = game.terrainMap.grid.cellSize * _spawnClearCells;
    final nearby = game.world.activeUnits.where(
      (u) =>
          u.team == Team.invaders && u.position.distanceTo(point) < clearRadius,
    );
    var count = 0;
    for (final _ in nearby) {
      count++;
      if (count >= _maxUnitsPerSpawnPoint) return true;
    }
    return false;
  }
}

/// A wave-definition spawn entry after aggression/composition-bias scaling,
/// before it's been split across entry points - see
/// [WaveDirectorComponent._planSpawnQueue].
class _ScaledSpawnEntry {
  final UnitKind type;
  final int count;
  final double interval;
  final double startDelay;
  _ScaledSpawnEntry({
    required this.type,
    required this.count,
    required this.interval,
    required this.startDelay,
  });
}

class _ScheduledSpawn {
  final UnitKind type;

  int remaining;
  final double interval;
  double timer;

  /// The world point this scheduled batch spawns at - assigned once by
  /// [WaveDirectorComponent._planSpawnQueue], not re-rolled per unit.
  final Vector2 spawnPoint;
  _ScheduledSpawn({
    required this.type,
    required this.remaining,
    required this.interval,
    required this.timer,
    required this.spawnPoint,
  });
}
