import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/widgets/window_controls.dart';
import '../../../generated/l10n.dart';
import '../../account/domain/models/account.dart';
import '../../account/domain/repos/account_repository.dart';
import '../../game_core/domain/models/game_difficulty.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../game_core/domain/models/game_scenes.dart';
import '../../game_core/presentation/game_page.dart';
import '../../progress/domain/models/progress_snapshot.dart';
import '../../progress/domain/repos/progress_repository.dart';
import '../../terrain/domain/models/biome.dart';
import 'biome_preview.dart';

/// Pre-game scene picker: choose a campaign (terrain + wave count +
/// strategy) before the battle begins.
class LevelSelectPage extends StatefulWidget {
  const LevelSelectPage({super.key});

  @override
  State<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _DifficultySegment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultySegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Colors.cyanAccent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.cyanAccent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.cyanAccent : Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

/// Segmented easy/normal/hard picker - scales AI aggression and rations the
/// Laser Lance build limit for the run about to start. Styled as a single
/// HUD panel (matching the build menu's tab strip) rather than loose chips.
class _DifficultySelector extends StatelessWidget {
  final GameDifficulty value;
  final ValueChanged<GameDifficulty> onChanged;

  const _DifficultySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A323C), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final difficulty in GameDifficulty.values)
            _DifficultySegment(
              label: difficulty.label,
              selected: value == difficulty,
              onTap: () => onChanged(difficulty),
            ),
        ],
      ),
    );
  }
}

class _LevelSelectPageState extends State<LevelSelectPage> {
  final ProgressRepository _progressRepository = getIt<ProgressRepository>();
  final AccountRepository _accountRepository = getIt<AccountRepository>();
  GameDifficulty _difficulty = GameDifficulty.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: Stack(
        children: [
          SafeArea(
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                              S.current.levelSelectTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: -0.2, end: 0),
                        const SizedBox(height: 6),
                        Text(
                              S.current.levelSelectSubtitle,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 80.ms)
                            .slideY(begin: -0.2, end: 0),
                        const SizedBox(height: 28),
                        FutureBuilder<Account?>(
                          future: _accountRepository.currentAccount(),
                          builder: (context, accountSnapshot) {
                            return FutureBuilder<ProgressSnapshot>(
                              future: _progressRepository.load(),
                              builder: (context, progressSnapshot) {
                                final progress =
                                    progressSnapshot.data ??
                                    ProgressSnapshot.empty;
                                final account = accountSnapshot.data;
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (account != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 18,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.account_circle,
                                              color: Colors.white54,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              account.name,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            const Icon(
                                              Icons.military_tech,
                                              color: Colors.cyanAccent,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${progress.totalScore}',
                                              style: const TextStyle(
                                                color: Colors.cyanAccent,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Center(
                                      child: _DifficultySelector(
                                        value: _difficulty,
                                        onChanged: (value) =>
                                            setState(() => _difficulty = value),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    GridView.count(
                                      shrinkWrap: true,
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: 1.4,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: [
                                        for (final (index, scene)
                                            in GameScenes.all.indexed)
                                          _SceneCard(
                                                scene: scene,
                                                progress: progress,
                                                difficulty: _difficulty,
                                              )
                                              .animate()
                                              .fadeIn(
                                                duration: 380.ms,
                                                delay: (120 + index * 90).ms,
                                              )
                                              .scale(
                                                begin: const Offset(0.92, 0.92),
                                                curve: Curves.easeOutCubic,
                                              ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(child: const WindowControls()),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xB31A1F26),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: IconButton(
                  tooltip: 'Back',
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  final GameScene scene;
  final ProgressSnapshot progress;
  final GameDifficulty difficulty;

  const _SceneCard({
    required this.scene,
    required this.progress,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final palette = scene.biome.palette;
    final completed = progress.isCompleted(scene.id);
    final bestWave = progress.bestWaveFor(scene.id);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GamePage(scene: scene, difficulty: difficulty),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'scene-preview-${scene.id}',
                child: BiomePreview(scene: scene),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GlassmorphicContainer(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    borderRadius: 14,
                    blur: 6,
                    border: 1.5,
                    linearGradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        palette.ridgeLight.withValues(alpha: 0.7),
                        palette.ridgeLight.withValues(alpha: 0.2),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (completed)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.greenAccent),
                              ),
                              child: Text(
                                S.current.sceneCompleted,
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          Text(
                            scene.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scene.briefing,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                S.current.wavesCount(scene.waveCount),
                                style: TextStyle(
                                  color: palette.ridgeLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              if (bestWave > 0) ...[
                                const SizedBox(width: 10),
                                Text(
                                  S.current.bestWaveReached(bestWave),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
