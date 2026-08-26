import 'package:flame/components.dart';

import '../../audio/domain/models/sfx_type.dart';
import '../../enemies/domain/models/enemy_type.dart';
import '../../enemies/presentation/enemy_component.dart';
import '../../enemies/presentation/green_soldier_component.dart';
import '../../enemies/presentation/heavy_soldier_component.dart';
import '../../game_core/domain/models/game_status.dart';
import '../../game_core/presentation/circuit_defense_game.dart';

/// Drives round progression: schedules enemy spawns for the current wave,
/// detects when a wave is cleared, and hands out the wave-clear gold bonus
/// or ends the run in victory once the final wave falls.
class WaveDirectorComponent extends Component
    with HasGameReference<CircuitDefenseGame> {
  int _nextWaveNumber = 1;
  bool _waveActive = false;
  double _preWaveTimer = 3;
  final List<_ScheduledSpawn> _queue = [];

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
    game.gameState.setWave(waveNumber, totalWaves: game.waveRepository.totalWaves);
    game.audioRepository.play(SfxType.waveStart, volume: 0.7);
    _queue
      ..clear()
      ..addAll(
        def.spawns.map(
          (e) => _ScheduledSpawn(
            type: e.type,
            remaining: e.count,
            interval: e.interval,
            timer: e.startDelay,
          ),
        ),
      );
    _waveActive = true;
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

  EnemyComponent _createEnemy(EnemyType type) {
    final blueprint = game.enemyRepository.blueprintFor(type);
    return switch (type) {
      EnemyType.soldier => GreenSoldierComponent(blueprint: blueprint),
      EnemyType.heavySoldier => HeavySoldierComponent(blueprint: blueprint),
    };
  }
}

class _ScheduledSpawn {
  _ScheduledSpawn({
    required this.type,
    required this.remaining,
    required this.interval,
    required this.timer,
  });

  final EnemyType type;
  int remaining;
  final double interval;
  double timer;
}
