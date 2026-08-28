import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/window_controls.dart';
import '../../../generated/l10n.dart';
import '../../game_core/domain/models/game_scenes.dart';
import '../../map_editor/domain/models/map_draft.dart';
import '../../map_editor/domain/repos/map_draft_repository.dart';
import 'state/skirmish_level_select_state.dart';
import 'widgets/skirmish_level_select_draft_tile_widget.dart';
import 'widgets/skirmish_level_select_scene_card_widget.dart';

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

class _SkirmishLevelSelectPageState extends State<SkirmishLevelSelectPage> {
  final SkirmishLevelSelectState _state = SkirmishLevelSelectState(
    getIt<MapDraftRepository>(),
  );

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
                            SkirmishLevelSelectSceneCardWidget(scene: scene)
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
                      ValueListenableBuilder<List<MapDraft>?>(
                        valueListenable: _state.drafts,
                        builder: (context, drafts, _) {
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
                                  child: SkirmishLevelSelectDraftTileWidget(
                                    draft: draft,
                                    onTap: () => context.push(
                                      Routes.skirmishPlacement.route,
                                      extra: SkirmishPlacementArgs(
                                        draft: draft,
                                      ),
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
                  tooltip: S.current.backTooltip,
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

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _state.load();
  }
}
