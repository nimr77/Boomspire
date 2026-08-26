import 'dart:async';

import 'package:flame/components.dart';

import '../../ai_director/domain/models/battlefield_snapshot.dart';
import '../../ai_director/domain/models/strategy_directive.dart';
import '../../audio/domain/models/sfx_type.dart';
import '../../enemies/domain/models/enemy_type.dart';
import '../../enemies/presentation/air_drone_component.dart';
import '../../enemies/presentation/enemy_component.dart';
import '../../enemies/presentation/green_soldier_component.dart';
import '../../enemies/presentation/heavy_soldier_component.dart';
import '../../game_core/domain/models/game_status.dart';
import '../../game_core/presentation/circuit_defense_game.dart';

/// Drives round progression: schedules enemy spawns for the current wave,
/// detects when a wave is cleared, and hands out the wave-clear gold bonus
/// or ends the run in victory once the final wave falls. Also consults the
/// AI director (Gemini, with a local fallback) once per wave to decide how
/// hard/what shape the *next* wave should be, and what enemies should
/// prioritize attacking.
class WaveDirectorComponent extends Component
    with HasGameReference<CircuitDefenseGame> {
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
        game.world.spawnEnemy(_createEnemy(scheduled.type));
        scheduled.remaining--;
        scheduled.timer = scheduled.interval;
        if (scheduled.remaining <= 0) _queue.remove(scheduled);
      }
    }

    if (_queue.isEmpty && game.world.activeEnemies.isEmpty) {
      _finishWave();
    }
  }

  void _beginWave(int waveNumber) {
    final def = game.waveRepository.waveDefinition(waveNumber);
    final directive = _directive ?? StrategyDirective.fallback(waveNumber);
    // Each scene can add its own opening-strategy pressure on top of
    // whatever the AI director (or its fallback) computed.
    final aggression = (directive.aggression + game.scene.aggressionBias)
        .clamp(0.0, 1.0);
    game.gameState.setWave(
      waveNumber,
      totalWaves: game.waveRepository.totalWaves,
    );
    game.enemyFocusHint = directive.focusHint;
    game.commanderNote.value = directive.commanderNote;
    game.audioRepository.play(SfxType.waveStart, volume: 0.7);
    _queue
      ..clear()
      ..addAll(
        def.spawns.map((e) {
          final bias = directive.compositionBias[e.type.name] ?? 1.0;
          final scaledCount = (e.count * (1 + aggression * 0.35) * bias)
              .round()
              .clamp(1, 60);
          return _ScheduledSpawn(
            type: e.type,
            remaining: scaledCount,
            interval: e.interval / (1 + aggression * 0.2),
            timer: e.startDelay,
          );
        }),
      );
    _waveActive = true;
    // Kick off planning for the wave after next while this one plays out, so
    // the Gemini call (if reachable) has the whole wave to complete.
    unawaited(_planNextWave(waveNumber + 1));
  }

  EnemyComponent _createEnemy(EnemyType type) {
    final blueprint = game.enemyRepository.blueprintFor(type);
    return switch (type) {
      EnemyType.soldier => GreenSoldierComponent(blueprint: blueprint),
      EnemyType.heavySoldier => HeavySoldierComponent(blueprint: blueprint),
      EnemyType.air => AirDroneComponent(blueprint: blueprint),
    };
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
          .add(tower.hp / tower.blueprint.maxHp);
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
}

class _ScheduledSpawn {
  final EnemyType type;

  int remaining;
  final double interval;
  double timer;
  _ScheduledSpawn({
    required this.type,
    required this.remaining,
    required this.interval,
    required this.timer,
  });
}
