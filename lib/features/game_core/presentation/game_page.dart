import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/widgets/window_controls.dart';
import '../../../generated/l10n.dart';
import '../../ai_director/domain/repos/ai_director_repository.dart';
import '../../audio/domain/repos/audio_repository.dart';
import '../../enemies/domain/repos/enemy_repository.dart';
import '../../level_select/presentation/biome_preview.dart';
import '../../progress/domain/repos/progress_repository.dart';
import '../../terrain/domain/repos/terrain_repository.dart';
import '../../towers/domain/repos/tower_repository.dart';
import '../../waves/domain/repos/wave_repository.dart';
import '../domain/models/game_difficulty.dart';
import '../domain/models/game_scene.dart';
import '../domain/models/game_status.dart';
import '../domain/repos/game_state_repository.dart';
import 'boomspire_game.dart';
import 'widgets/game_over_overlay.dart';
import 'widgets/hud_overlay.dart';
import 'widgets/tower_action_panel.dart';
import 'widgets/victory_overlay.dart';

/// Hosts the [GameWidget] and keeps its Flutter overlays (HUD / game-over /
/// victory) in sync with the game's [GameStatus].
class GamePage extends StatefulWidget {
  final GameScene scene;
  final GameDifficulty difficulty;

  const GamePage({
    super.key,
    required this.scene,
    this.difficulty = GameDifficulty.normal,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final BoomspireGame _game;
  late final GameStateRepository _gameState;
  final ProgressRepository _progressRepository = getIt<ProgressRepository>();
  bool _recorded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      // The command bar is a normal sibling widget (not a Flame overlay) so
      // the GameWidget above it is only ever given the remaining screen
      // space - the arena is letterboxed inside that shrunk area, so
      // nothing in it (including the home base, which can be placed
      // anywhere) ever ends up rendered underneath the bar.
      body: Stack(
        children: [
          // Hero destination: the same terrain preview the level-select
          // card animated in from, shown beneath the game while it loads.
          Positioned.fill(
            child: Hero(
              tag: 'scene-preview-${widget.scene.id}',
              child: BiomePreview(scene: widget.scene),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SoftEdgeBlur(
                  edges: [
                    EdgeBlur(
                      type: EdgeType.topEdge,
                      size: 60,
                      sigma: 20,
                      controlPoints: [
                        ControlPoint(
                          position: 0,
                          type: ControlPointType.visible,
                        ),
                        ControlPoint(
                          position: 1,
                          type: ControlPointType.transparent,
                        ),
                      ],
                    ),
                  ],
                  child: GameWidget<BoomspireGame>(
                    game: _game,
                    overlayBuilderMap: {
                      'gameOver': (context, game) =>
                          GameOverOverlay(game: game),
                      'victory': (context, game) => VictoryOverlay(game: game),
                    },
                  ),
                ),
              ),
              HudOverlay(game: _game),
            ],
          ),
          // Floats over the game canvas (doesn't resize the letterboxed
          // arena the way a Column sibling would) - docked just above the
          // command bar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 112,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TowerActionPanel(game: _game),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(child: WindowControls(onExit: _confirmExit)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameState.removeListener(_syncOverlays);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _gameState = getIt<GameStateRepository>();
    _game = BoomspireGame(
      terrainRepository: getIt<TerrainRepository>(),
      towerRepository: getIt<TowerRepository>(),
      enemyRepository: getIt<EnemyRepository>(),
      waveRepository: getIt<WaveRepository>(
        param1: widget.scene.waveCount,
        param2: widget.scene.biome,
      ),
      audioRepository: getIt<AudioRepository>(),
      gameState: _gameState,
      aiDirector: getIt<AiDirectorRepository>(),
      scene: widget.scene,
      difficulty: widget.difficulty,
    )..onExitToMenu = () => Navigator.of(context).pop();
    _gameState.addListener(_syncOverlays);
  }

  Future<void> _confirmExit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: Text(
          S.current.exitConfirmTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          S.current.exitConfirmBody,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.current.exitConfirmCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              S.current.exitConfirmConfirm,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) Navigator.of(context).pop();
  }

  void _recordProgress() {
    if (_recorded) return;
    _recorded = true;
    final completed = _gameState.status == GameStatus.victory;
    final score = _gameState.currentScore + (completed ? 1000 : 0);
    _progressRepository.recordRun(
      sceneId: widget.scene.id,
      waveReached: _gameState.currentWave,
      completed: completed,
      score: score,
    );
  }

  void _syncOverlays() {
    switch (_gameState.status) {
      case GameStatus.gameOver:
        _game.overlays.add('gameOver');
        _recordProgress();
      case GameStatus.victory:
        _game.overlays.add('victory');
        _recordProgress();
      case GameStatus.playing:
        _game.overlays
          ..remove('gameOver')
          ..remove('victory');
        _recorded = false;
    }
  }
}
