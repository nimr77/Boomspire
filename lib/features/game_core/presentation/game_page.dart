import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../audio/impl/audio_repository_impl.dart';
import '../../enemies/impl/enemy_repository_impl.dart';
import '../../terrain/impl/terrain_repository_impl.dart';
import '../../towers/impl/tower_repository_impl.dart';
import '../../waves/impl/wave_repository_impl.dart';
import '../domain/models/game_status.dart';
import '../impl/game_state_repository_impl.dart';
import 'circuit_defense_game.dart';
import 'widgets/game_over_overlay.dart';
import 'widgets/hud_overlay.dart';
import 'widgets/victory_overlay.dart';

/// Hosts the [GameWidget] and keeps its Flutter overlays (HUD / game-over /
/// victory) in sync with the game's [GameStatus].
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final CircuitDefenseGame _game;
  late final GameStateRepositoryImpl _gameState;

  @override
  void initState() {
    super.initState();
    _gameState = GameStateRepositoryImpl();
    _game = CircuitDefenseGame(
      terrainRepository: TerrainRepositoryImpl(),
      towerRepository: TowerRepositoryImpl(),
      enemyRepository: EnemyRepositoryImpl(),
      waveRepository: WaveRepositoryImpl(),
      audioRepository: AudioRepositoryImpl(),
      gameState: _gameState,
    );
    _gameState.addListener(_syncOverlays);
  }

  void _syncOverlays() {
    switch (_gameState.status) {
      case GameStatus.gameOver:
        _game.overlays.add('gameOver');
      case GameStatus.victory:
        _game.overlays.add('victory');
      case GameStatus.playing:
        _game.overlays
          ..remove('gameOver')
          ..remove('victory');
    }
  }

  @override
  void dispose() {
    _gameState.removeListener(_syncOverlays);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: GameWidget<CircuitDefenseGame>(
        game: _game,
        overlayBuilderMap: {
          'hud': (context, game) => HudOverlay(game: game),
          'gameOver': (context, game) => GameOverOverlay(game: game),
          'victory': (context, game) => VictoryOverlay(game: game),
        },
        initialActiveOverlays: const ['hud'],
      ),
    );
  }
}
