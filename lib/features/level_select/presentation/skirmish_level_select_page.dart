import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/window_controls.dart';
import '../../../generated/l10n.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../game_core/domain/models/game_scenes.dart';
import '../../map_editor/domain/models/map_draft.dart';
import '../../map_editor/domain/repos/map_draft_repository.dart';
import '../../terrain/domain/models/biome.dart';
import 'biome_preview.dart';

/// Skirmish map picker: lists the built-in "Featured" skirmish scenes plus
/// any user-authored [MapDraft]s saved in [GameMode.skirmish] mode from the
/// map editor.
///
/// Picking a map opens [SkirmishPlacementPage] to preview the battlefield
/// and claim a starting site before the match launches.
class SkirmishLevelSelectPage extends StatefulWidget {
  const SkirmishLevelSelectPage({super.key});

  @override
  State<SkirmishLevelSelectPage> createState() =>
      _SkirmishLevelSelectPageState();
}

class _SkirmishDraftTile extends StatelessWidget {
  final MapDraft draft;
  final VoidCallback onTap;

  const _SkirmishDraftTile({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF161B22),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: const Icon(Icons.map_outlined, color: Colors.redAccent),
          title: Text(draft.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            '${draft.biome.displayName} · ${draft.homeSites.length} '
            'home site${draft.homeSites.length == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.white54),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        ),
      ),
    );
  }
}

class _SkirmishLevelSelectPageState extends State<SkirmishLevelSelectPage> {
  final MapDraftRepository _draftRepository = getIt<MapDraftRepository>();
  late final Future<List<MapDraft>> _draftsFuture = _loadSkirmishDrafts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                                  S.current.skirmishSelectTitle,
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
                                  S.current.skirmishSelectSubtitle,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 16,
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 80.ms)
                                .slideY(begin: -0.2, end: 0),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        S.current.skirmishSelectFeatured,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.4,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final (index, scene)
                              in GameScenes.skirmishes.indexed)
                            _SkirmishSceneCard(scene: scene)
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
                      const SizedBox(height: 28),
                      Text(
                        S.current.skirmishSelectCustomMaps,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<MapDraft>>(
                        future: _draftsFuture,
                        builder: (context, snapshot) {
                          final drafts = snapshot.data;
                          if (drafts == null) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (drafts.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                S.current.skirmishSelectEmptyCustom,
                                style: const TextStyle(color: Colors.white38),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              for (final draft in drafts)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _SkirmishDraftTile(
                                    draft: draft,
                                    onTap: () => context.push(
                                      Routes.skirmishPlacement.route,
                                      extra: SkirmishPlacementArgs(draft: draft),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
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
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<MapDraft>> _loadSkirmishDrafts() async {
    final drafts = await _draftRepository.listDrafts();
    return drafts.where((d) => d.mode == GameMode.skirmish).toList();
  }
}

class _SkirmishSceneCard extends StatelessWidget {
  final GameScene scene;

  const _SkirmishSceneCard({required this.scene});

  @override
  Widget build(BuildContext context) {
    final palette = scene.biome.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(
          Routes.skirmishPlacement.route,
          extra: SkirmishPlacementArgs(scene: scene),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              BiomePreview(scene: scene),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                  border: Border.all(
                    color: palette.ridgeLight.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
