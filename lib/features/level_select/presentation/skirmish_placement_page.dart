import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/widgets/window_controls.dart';
import '../../../generated/l10n.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../game_core/presentation/game_page.dart';
import '../../game_core/presentation/home_site_marker_painter.dart';
import '../../game_core/presentation/player_palette.dart';
import '../../map_editor/domain/models/editor_point.dart';
import '../../map_editor/domain/models/editor_terrain_preview.dart';
import '../../map_editor/domain/models/map_draft.dart';
import '../../map_editor/impl/editor_terrain_generator.dart';
import '../../map_editor/impl/map_draft_terrain_repository.dart';
import '../../terrain/domain/models/biome.dart';
import '../../terrain/presentation/obstacle_color.dart';
import 'biome_preview.dart';

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

/// Lightweight read-only terrain preview (biome gradient + rasterized
/// obstacle cells, no sun/weather) - enough to see the map's shape while
/// picking a starting site.
class _DraftPreviewPainter extends CustomPainter {
  final EditorTerrainPreview preview;

  _DraftPreviewPainter({required this.preview});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final palette = preview.biome.palette;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, size.height),
          [palette.groundTop, palette.groundMid, palette.groundBottom],
          const [0.0, 0.5, 1.0],
        ),
    );

    final grid = preview.grid;
    if (grid.cols == 0 || grid.rows == 0) return;
    final cellW = size.width / grid.cols;
    final cellH = size.height / grid.rows;
    for (var row = 0; row < grid.rows; row++) {
      for (var col = 0; col < grid.cols; col++) {
        final kind = preview.obstacleKinds[row][col];
        if (kind == null) continue;
        canvas.drawRect(
          Rect.fromLTWH(col * cellW, row * cellH, cellW, cellH),
          Paint()..color = obstacleColor(kind, palette),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DraftPreviewPainter oldDelegate) =>
      oldDelegate.preview != preview;
}

class _MarkerPainter extends CustomPainter {
  final List<Offset> sites;
  final int? selectedSlot;

  _MarkerPainter({required this.sites, required this.selectedSlot});

  @override
  void paint(Canvas canvas, Size size) {
    for (final (index, fraction) in sites.indexed) {
      final center = Offset(fraction.dx * size.width, fraction.dy * size.height);
      paintHomeSiteMarker(
        canvas,
        center,
        index,
        radius: 18,
        highlighted: index == selectedSlot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MarkerPainter oldDelegate) =>
      oldDelegate.sites != sites || oldDelegate.selectedSlot != selectedSlot;
}

/// Renders [background] with a numbered/colored marker per fractional site
/// position, and reports taps near a marker via [onTapSlot].
class _PlacementSurface extends StatelessWidget {
  final List<Offset> sites;
  final int? selectedSlot;
  final ValueChanged<int> onTapSlot;
  final Widget background;

  const _PlacementSurface({
    required this.sites,
    required this.selectedSlot,
    required this.onTapSlot,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onTapUp: (details) {
            for (final (index, fraction) in sites.indexed) {
              final center = Offset(
                fraction.dx * size.width,
                fraction.dy * size.height,
              );
              if ((details.localPosition - center).distance <= 22) {
                onTapSlot(index);
                return;
              }
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              background,
              CustomPaint(
                painter: _MarkerPainter(
                  sites: sites,
                  selectedSlot: selectedSlot,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeatChip extends StatelessWidget {
  final int index;
  final bool isYou;

  const _SeatChip({required this.index, required this.isYou});

  @override
  Widget build(BuildContext context) {
    final color = PlayerPalette.colorFor(index);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isYou ? 0.35 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: isYou ? 2 : 1),
      ),
      child: Text(
        '${index + 1} · ${isYou ? S.current.skirmishPlacementYou : S.current.skirmishPlacementAi}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: isYou ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _SkirmishPlacementPageState extends State<SkirmishPlacementPage> {
  late final Future<EditorTerrainPreview>? _draftPreviewFuture = widget.draft ==
          null
      ? null
      : EditorTerrainGenerator().generate(widget.draft!);

  int? _selectedSlot;
  bool _launching = false;

  bool get _isDraft => widget.draft != null;
  int get _siteCount =>
      widget.draft?.homeSites.length ?? widget.scene?.homeSites.length ?? 0;

  @override
  Widget build(BuildContext context) {
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
                                ? FutureBuilder<EditorTerrainPreview>(
                                    future: _draftPreviewFuture,
                                    builder: (context, snapshot) {
                                      final preview = snapshot.data;
                                      if (preview == null) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      return _PlacementSurface(
                                        sites: widget.draft!.homeSites
                                            .map((p) => Offset(
                                                  p.x / widget.draft!.arenaWidth,
                                                  p.y / widget.draft!.arenaHeight,
                                                ))
                                            .toList(),
                                        selectedSlot: _selectedSlot,
                                        onTapSlot: _selectSlot,
                                        background: CustomPaint(
                                          painter: _DraftPreviewPainter(
                                            preview: preview,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : _PlacementSurface(
                                    sites: widget.scene!.homeSites
                                        .map((s) => _fractionForLayout(s.layout))
                                        .toList(),
                                    selectedSlot: _selectedSlot,
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
                            _SeatChip(
                              index: i,
                              isYou: _selectedSlot == i,
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
                            label: Text(S.current.skirmishPlacementRandomize),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                            ),
                          ),
                        if (_isDraft) const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _launching ? null : _start,
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
            Positioned(
              top: 12,
              right: 12,
              child: const WindowControls(),
            ),
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
            if (_launching)
              const ColoredBox(
                color: Color(0x99000000),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (!_isDraft) {
      final sites = widget.scene!.homeSites;
      final playerIndex = sites.indexWhere(
        (s) => s.owner == HomeSiteOwner.player,
      );
      _selectedSlot = playerIndex >= 0 ? playerIndex : null;
    }
  }

  void _randomize() {
    if (_siteCount == 0) return;
    setState(() => _selectedSlot = Random().nextInt(_siteCount));
  }

  void _selectSlot(int index) {
    if (!_isDraft) return; // Built-in scenes have fixed ownership.
    setState(() => _selectedSlot = index);
  }

  Future<void> _start() async {
    if (_isDraft && _siteCount > 0 && _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.skirmishPlacementPickHint)),
      );
      return;
    }

    if (!_isDraft) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => GamePage(scene: widget.scene!)));
      return;
    }

    setState(() => _launching = true);
    final preview = await _draftPreviewFuture!;
    if (!mounted) return;
    setState(() => _launching = false);

    final draft = widget.draft!;
    final chosen = _selectedSlot != null
        ? draft.homeSites[_selectedSlot!]
        : null;
    // The AI takes the first other declared site - today's map editor
    // always gives a skirmish-flagged draft at least two home sites (one
    // per seat). If, for whatever reason, there isn't a second site to
    // hand to the AI, fall back to a single-base test-play instead of
    // launching a skirmish with no opposing base to fight.
    EditorPoint? aiSite;
    for (var i = 0; i < draft.homeSites.length; i++) {
      if (i != _selectedSlot) {
        aiSite = draft.homeSites[i];
        break;
      }
    }
    if (aiSite == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Testing as single-base - add another home site for a full skirmish.'),
        ),
      );
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GamePage(
          scene: GameScene(
            id: 'draft-${draft.id}',
            name: draft.name.isEmpty ? 'Untitled Map' : draft.name,
            briefing: 'Testing your hand-drawn skirmish map.',
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
      ),
    );
  }
}
