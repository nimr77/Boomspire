import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/widgets/window_controls.dart';
import '../../../generated/l10n.dart';
import '../../game_core/domain/models/game_scene.dart';
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

/// A single numbered, colored home-site marker that glows and scales up on
/// hover, and reports taps via [onTap].
class _HomeSiteMarker extends StatelessWidget {
  static const _radius = 18.0;
  static const _hitPadding = 10.0;

  final Offset center;
  final int index;
  final bool selected;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;

  const _HomeSiteMarker({
    required this.center,
    required this.index,
    required this.selected,
    required this.hovered,
    required this.onHoverChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = PlayerPalette.colorFor(index);
    const diameter = _radius * 2;
    const hitSize = diameter + _hitPadding * 2;
    return Positioned(
      left: center.dx - hitSize / 2,
      top: center.dy - hitSize / 2,
      width: hitSize,
      height: hitSize,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => onHoverChanged(true),
        onExit: (_) => onHoverChanged(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: AnimatedScale(
              scale: hovered ? 1.25 : 1.0,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: Colors.white,
                    width: selected ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: hovered ? 0.9 : 0.35),
                      blurRadius: hovered ? 20 : 6,
                      spreadRadius: hovered ? 4 : 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders [background] with a numbered/colored marker per fractional site
/// position, and reports taps near a marker via [onTapSlot]. Each marker is
/// a real interactive widget (not just painted pixels) so it can glow and
/// scale up under the mouse.
class _PlacementSurface extends StatefulWidget {
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
  State<_PlacementSurface> createState() => _PlacementSurfaceState();
}

class _PlacementSurfaceState extends State<_PlacementSurface> {
  int? _hoveredSlot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          children: [
            widget.background,
            for (final (index, fraction) in widget.sites.indexed)
              _HomeSiteMarker(
                center: Offset(
                  fraction.dx * size.width,
                  fraction.dy * size.height,
                ),
                index: index,
                selected: widget.selectedSlot == index,
                hovered: _hoveredSlot == index,
                onHoverChanged: (hovering) =>
                    setState(() => _hoveredSlot = hovering ? index : null),
                onTap: () => widget.onTapSlot(index),
              ),
          ],
        );
      },
    );
  }
}

class _SeatChip extends StatefulWidget {
  final int index;
  final bool isYou;

  const _SeatChip({required this.index, required this.isYou});

  @override
  State<_SeatChip> createState() => _SeatChipState();
}

class _SeatChipState extends State<_SeatChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = PlayerPalette.colorFor(widget.index);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: widget.isYou ? 0.35 : 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: widget.isYou ? 2 : 1),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.7),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ]
                : const [],
          ),
          child: Text(
            '${widget.index + 1} · ${widget.isYou ? S.current.skirmishPlacementYou : S.current.skirmishPlacementAi}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: widget.isYou ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _SkirmishPlacementPageState extends State<SkirmishPlacementPage> {
  late final Future<EditorTerrainPreview>? _draftPreviewFuture =
      widget.draft == null
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
                                            .map(
                                              (p) => Offset(
                                                p.x / widget.draft!.arenaWidth,
                                                p.y / widget.draft!.arenaHeight,
                                              ),
                                            )
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
                                        .map(
                                          (s) => _fractionForLayout(s.layout),
                                        )
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
                            _SeatChip(index: i, isYou: _selectedSlot == i),
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

  /// The scene to actually launch for a built-in (non-draft) map: unchanged
  /// unless the player picked a different site than the one already
  /// flagged [HomeSiteOwner.player] in the scene data, in which case the
  /// two sites' ownership is swapped so the player starts where they
  /// tapped and the AI takes over the original player site instead.
  GameScene _sceneForLaunch() {
    final scene = widget.scene!;
    final playerIndex = scene.homeSites.indexWhere(
      (s) => s.owner == HomeSiteOwner.player,
    );
    if (_selectedSlot == null || _selectedSlot == playerIndex) return scene;
    final sites = [
      for (final (i, site) in scene.homeSites.indexed)
        if (i == _selectedSlot)
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
      await context.push(
        Routes.game.route,
        extra: GameRouteArgs(scene: _sceneForLaunch()),
      );
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
          content: Text(
            'Testing as single-base - add another home site for a full skirmish.',
          ),
        ),
      );
    }
    await context.push(
      Routes.game.route,
      extra: GameRouteArgs(
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
    );
  }
}
