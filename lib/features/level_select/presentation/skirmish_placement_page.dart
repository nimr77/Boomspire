import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/widgets/window_controls.dart';
import '../../../generated/l10n.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../map_editor/domain/models/editor_point.dart';
import '../../map_editor/domain/models/editor_terrain_preview.dart';
import '../../map_editor/domain/models/map_draft.dart';
import '../../map_editor/impl/map_draft_terrain_repository.dart';
import 'biome_preview.dart';
import 'state/skirmish_placement_state.dart';
import 'widgets/skirmish_placement_draft_preview_painter.dart';
import 'widgets/skirmish_placement_seat_chip_widget.dart';
import 'widgets/skirmish_placement_surface_widget.dart';

/// Maps a built-in scene's [HomeLayout] to a fractional position within the
/// arena - matches the cell math `TerrainRepositoryImpl` uses so the marker
/// lands where the real base will spawn.
Offset _fractionForLayout(HomeLayout layout) => switch (layout) {
  HomeLayout.eastEdge => const Offset(0.94, 0.5),
  HomeLayout.center => const Offset(0.5, 0.5),
  HomeLayout.northEastCorner => const Offset(0.88, 0.12),
  HomeLayout.southWestCorner => const Offset(0.12, 0.88),
};

/// Pre-game placement/preview screen shown after picking a skirmish map:
/// lets the player see the battlefield and claim one of its numbered,
/// colored home sites (manually or via [_randomize]) before the match
/// starts.
///
/// Provide exactly one of [scene] (a built-in skirmish scene, whose seats
/// already have fixed ownership) or [draft] (a hand-authored map, whose
/// home sites have no owner yet and must be claimed here).
class SkirmishPlacementPage extends StatefulWidget {
  final GameScene? scene;
  final MapDraft? draft;

  const SkirmishPlacementPage({super.key, this.scene, this.draft})
    : assert(
        (scene == null) != (draft == null),
        'Provide exactly one of scene or draft',
      );

  @override
  State<SkirmishPlacementPage> createState() => _SkirmishPlacementPageState();
}

class _SkirmishPlacementPageState extends State<SkirmishPlacementPage> {
  final SkirmishPlacementState _placementState = SkirmishPlacementState();

  bool get _isDraft => widget.draft != null;
  int get _siteCount =>
      widget.draft?.homeSites.length ?? widget.scene?.homeSites.length ?? 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _placementState.selectedSlot,
        _placementState.launching,
      ]),
      builder: (context, _) {
        final selectedSlot = _placementState.selectedSlot.value;
        final launching = _placementState.launching.value;
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E14),
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                              S.current.skirmishPlacementTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: -0.2, end: 0),
                        const SizedBox(height: 6),
                        Text(
                          _isDraft
                              ? S.current.skirmishPlacementSubtitleDraft
                              : S.current.skirmishPlacementSubtitleScene,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: _isDraft
                                    ? ValueListenableBuilder<
                                        EditorTerrainPreview?
                                      >(
                                        valueListenable:
                                            _placementState.preview,
                                        builder: (context, preview, _) {
                                          if (preview == null) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                          return SkirmishPlacementSurfaceWidget(
                                            sites: widget.draft!.homeSites
                                                .map(
                                                  (p) => Offset(
                                                    p.x /
                                                        widget
                                                            .draft!
                                                            .arenaWidth,
                                                    p.y /
                                                        widget
                                                            .draft!
                                                            .arenaHeight,
                                                  ),
                                                )
                                                .toList(),
                                            selectedSlot: selectedSlot,
                                            onTapSlot: _selectSlot,
                                            background: CustomPaint(
                                              painter:
                                                  SkirmishPlacementDraftPreviewPainter(
                                                    preview: preview,
                                                  ),
                                            ),
                                          );
                                        },
                                      )
                                    : SkirmishPlacementSurfaceWidget(
                                        sites: widget.scene!.homeSites
                                            .map(
                                              (s) =>
                                                  _fractionForLayout(s.layout),
                                            )
                                            .toList(),
                                        selectedSlot: selectedSlot,
                                        onTapSlot: _selectSlot,
                                        background: BiomePreview(
                                          scene: widget.scene!,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_siteCount > 0)
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              for (var i = 0; i < _siteCount; i++)
                                SkirmishPlacementSeatChipWidget(
                                  index: i,
                                  isYou: selectedSlot == i,
                                ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isDraft)
                              OutlinedButton.icon(
                                onPressed: _randomize,
                                icon: const Icon(Icons.shuffle),
                                label: Text(
                                  S.current.skirmishPlacementRandomize,
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white38),
                                ),
                              ),
                            if (_isDraft) const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: launching ? null : _start,
                              icon: const Icon(Icons.play_arrow),
                              label: Text(S.current.skirmishPlacementStart),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(top: 12, right: 12, child: const WindowControls()),
                Positioned(
                  top: 12,
                  left: 12,
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
                if (launching)
                  const ColoredBox(
                    color: Color(0x99000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _placementState.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (_isDraft) {
      _placementState.load(widget.draft!);
    } else {
      final sites = widget.scene!.homeSites;
      final playerIndex = sites.indexWhere(
        (s) => s.owner == HomeSiteOwner.player,
      );
      _placementState.selectSlot(playerIndex >= 0 ? playerIndex : null);
    }
  }

  void _randomize() {
    if (_siteCount == 0) return;
    _placementState.selectSlot(Random().nextInt(_siteCount));
  }

  /// The scene to actually launch for a built-in (non-draft) map: unchanged
  /// unless the player picked a different site than the one already
  /// flagged [HomeSiteOwner.player] in the scene data, in which case the
  /// two sites' ownership is swapped so the player starts where they
  /// tapped and the AI takes over the original player site instead.
  GameScene _sceneForLaunch() {
    final scene = widget.scene!;
    final selectedSlot = _placementState.selectedSlot.value;
    final playerIndex = scene.homeSites.indexWhere(
      (s) => s.owner == HomeSiteOwner.player,
    );
    if (selectedSlot == null || selectedSlot == playerIndex) return scene;
    final sites = [
      for (final (i, site) in scene.homeSites.indexed)
        if (i == selectedSlot)
          HomeSite(layout: site.layout, owner: HomeSiteOwner.player)
        else if (i == playerIndex)
          HomeSite(layout: site.layout, owner: HomeSiteOwner.ai)
        else
          site,
    ];
    return GameScene(
      id: scene.id,
      name: scene.name,
      briefing: scene.briefing,
      biome: scene.biome,
      mode: scene.mode,
      waveCount: scene.waveCount,
      aggressionBias: scene.aggressionBias,
      homeLayout: scene.homeLayout,
      spawnLayout: scene.spawnLayout,
      homeSites: sites,
      resourceNodeSites: scene.resourceNodeSites,
      startingGold: scene.startingGold,
    );
  }

  void _selectSlot(int index) {
    _placementState.selectSlot(index);
  }

  Future<void> _start() async {
    if (_isDraft &&
        _siteCount > 0 &&
        _placementState.selectedSlot.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.skirmishPlacementPickHint)),
      );
      return;
    }

    if (!_isDraft) {
      await context.push(
        Routes.game.route,
        extra: GameRouteArgs(scene: _sceneForLaunch()),
      );
      return;
    }

    _placementState.setLaunching(true);
    final preview = await _placementState.load(widget.draft!);
    if (!mounted) return;
    _placementState.setLaunching(false);

    final selectedSlot = _placementState.selectedSlot.value;
    final draft = widget.draft!;
    final chosen = selectedSlot != null ? draft.homeSites[selectedSlot] : null;
    // The AI takes the first other declared site - today's map editor
    // always gives a skirmish-flagged draft at least two home sites (one
    // per seat). If, for whatever reason, there isn't a second site to
    // hand to the AI, fall back to a single-base test-play instead of
    // launching a skirmish with no opposing base to fight.
    EditorPoint? aiSite;
    for (var i = 0; i < draft.homeSites.length; i++) {
      if (i != selectedSlot) {
        aiSite = draft.homeSites[i];
        break;
      }
    }
    if (aiSite == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.skirmishPlacementSingleBaseNotice)),
      );
    }
    await context.push(
      Routes.game.route,
      extra: GameRouteArgs(
        scene: GameScene(
          id: 'draft-${draft.id}',
          name: draft.name.isEmpty
              ? S.current.untitledMapEditorPage
              : draft.name,
          briefing: S.current.skirmishPlacementTestBriefing,
          biome: draft.biome,
          mode: aiSite != null ? GameMode.skirmish : GameMode.waveDefense,
          startingGold: draft.startingGold,
        ),
        terrainRepository: MapDraftTerrainRepository(
          draft: draft,
          preview: preview,
          humanBaseSite: chosen,
          aiBaseSite: aiSite,
        ),
      ),
    );
  }
}
