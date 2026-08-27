import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../game_core/presentation/game_page.dart';
import '../../game_core/presentation/home_site_marker_painter.dart';
import '../../game_core/presentation/player_palette.dart';
import '../../terrain/domain/models/biome.dart';
import '../../terrain/domain/models/obstacle_kind.dart';
import '../../terrain/presentation/obstacle_color.dart';
import '../domain/models/editor_point.dart';
import '../domain/models/editor_terrain_preview.dart';
import '../domain/models/environment_settings.dart';
import '../domain/models/map_draft.dart';
import '../domain/models/painted_cell.dart';
import '../domain/models/water_path.dart';
import '../domain/models/weather_keyframe.dart';
import '../domain/repos/map_draft_repository.dart';
import '../impl/editor_terrain_generator.dart';
import '../impl/map_draft_terrain_repository.dart';

/// The map editor: paint terrain obstacles, draw freehand rivers/lakes,
/// size the arena, and author the scene's sun/weather timeline.
///
/// Terrain rasterization ([EditorTerrainGenerator]) runs on a background
/// isolate and is debounced so dragging a brush never blocks the canvas.
class MapEditorPage extends StatefulWidget {
  final MapDraft initialDraft;

  const MapEditorPage({super.key, required this.initialDraft});

  @override
  State<MapEditorPage> createState() => _MapEditorPageState();
}

/// HUD-panel-styled action button for the editor's AppBar (Save/Play) -
/// matches the translucent bordered look used by in-game action buttons
/// rather than a stock Material [FilledButton].
class _EditorAppBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback? onPressed;

  const _EditorAppBarButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final tint = disabled ? color.withValues(alpha: 0.4) : color;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xB31A1F26),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: tint.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tint,
                    ),
                  )
                else
                  Icon(icon, color: tint, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: tint,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted, auto-dismissing confirmation toast - the non-modal counterpart
/// to the game's [showGlassMessage] sheet, used for brief editor feedback
/// (saved, playtest notes) that shouldn't block interaction.
class _EditorToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback onDismissed;

  const _EditorToast({
    required this.message,
    required this.icon,
    required this.onDismissed,
  });

  @override
  State<_EditorToast> createState() => _EditorToastState();
}

class _EditorToastState extends State<_EditorToast>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 180),
  );
  Timer? _dismissTimer;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return Positioned(
      left: 0,
      right: 0,
      bottom: 32,
      child: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(curved),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.14),
                          Colors.white.withValues(alpha: 0.04),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.cyanAccent.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon, color: Colors.cyanAccent, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _dismissTimer = Timer(const Duration(milliseconds: 2200), _dismiss);
  }

  Future<void> _dismiss() async {
    _dismissTimer?.cancel();
    await _controller.reverse();
    widget.onDismissed();
  }
}

enum _EditorTool { mountain, dune, erase, river, lake, homeSite }

class _MapEditorPageState extends State<MapEditorPage> {
  final MapDraftRepository _draftRepository = getIt<MapDraftRepository>();
  final _generator = EditorTerrainGenerator();
  final _nameController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _startingGoldController = TextEditingController();

  late MapDraft _draft = widget.initialDraft;
  EditorTerrainPreview? _preview;
  _EditorTool _tool = _EditorTool.mountain;
  double _riverWidth = 48;
  List<EditorPoint> _activeStroke = [];
  Size _canvasSize = const Size(900, 540);
  Timer? _regenDebounce;
  int _generation = 0;
  bool _saving = false;
  bool _playing = false;

  /// Zoom applied to the canvas viewport only - doesn't affect the draft.
  final _viewerController = TransformationController();
  double _zoom = 1.0;

  /// Which point of the weather timeline (0..1) the canvas previews live.
  double _previewProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11161D),
        title: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) => _updateDraft((d) => d.copyWith(name: value)),
        ),
        actions: [
          _EditorAppBarButton(
            icon: Icons.play_arrow,
            label: 'Play',
            color: Colors.lightGreenAccent,
            loading: _playing,
            onPressed: _playing ? null : _play,
          ),
          _EditorAppBarButton(
            icon: Icons.save,
            label: 'Save',
            color: Colors.cyanAccent,
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Zoom out',
                        icon: const Icon(Icons.remove, color: Colors.white70),
                        onPressed: () => _zoomBy(1 / 1.25),
                      ),
                      Text(
                        '${(_zoom * 100).round()}%',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      IconButton(
                        tooltip: 'Zoom in',
                        icon: const Icon(Icons.add, color: Colors.white70),
                        onPressed: () => _zoomBy(1.25),
                      ),
                      IconButton(
                        tooltip: 'Reset zoom',
                        icon: const Icon(
                          Icons.center_focus_weak,
                          color: Colors.white70,
                        ),
                        onPressed: _resetZoom,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final aspect = _draft.arenaWidth / _draft.arenaHeight;
                          var width = constraints.maxWidth;
                          var height = width / aspect;
                          if (height > constraints.maxHeight) {
                            height = constraints.maxHeight;
                            width = height * aspect;
                          }
                          _canvasSize = Size(width, height);
                          return Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 24,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Listener(
                              onPointerSignal: (event) {
                                if (event is PointerScrollEvent) {
                                  _zoomBy(
                                    event.scrollDelta.dy < 0 ? 1.1 : 1 / 1.1,
                                  );
                                }
                              },
                              child: InteractiveViewer(
                                transformationController: _viewerController,
                                panEnabled: false,
                                scaleEnabled: true,
                                minScale: 1,
                                maxScale: 4,
                                onInteractionEnd: (_) => setState(
                                  () => _zoom = _viewerController.value
                                      .getMaxScaleOnAxis(),
                                ),
                                child: GestureDetector(
                                  onPanStart: _handlePanStart,
                                  onPanUpdate: _handlePanUpdate,
                                  onPanEnd: _handlePanEnd,
                                  child: CustomPaint(
                                    size: _canvasSize,
                                    painter: _MapEditorPainter(
                                      preview: _preview,
                                      activeStroke: _activeStroke,
                                      tool: _tool,
                                      arenaWidth: _draft.arenaWidth,
                                      arenaHeight: _draft.arenaHeight,
                                      environment: _draft.environment,
                                      previewProgress: _previewProgress,
                                      homeSites: _draft.homeSites,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
            child: SizedBox(
              width: 320,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF11161D),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _SectionLabel('Brush'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tool in _EditorTool.values)
                          if (tool != _EditorTool.homeSite ||
                              _draft.mode == GameMode.skirmish)
                            ChoiceChip(
                              label: Text(tool.label),
                              selected: _tool == tool,
                              onSelected: (_) => setState(() => _tool = tool),
                            ),
                      ],
                    ),
                    if (_tool == _EditorTool.homeSite) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Home sites: ${_draft.homeSites.length}/'
                        '${PlayerPalette.colors.length} - tap to place, tap '
                        'a marker to remove.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (_tool == _EditorTool.river) ...[
                      const SizedBox(height: 8),
                      Text(
                        'River width: ${_riverWidth.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Slider(
                        value: _riverWidth,
                        min: 16,
                        max: 160,
                        onChanged: (value) =>
                            setState(() => _riverWidth = value),
                      ),
                    ],
                    const Divider(color: Colors.white24, height: 32),
                    _SectionLabel('Map'),
                    DropdownButtonFormField<Biome>(
                      initialValue: _draft.biome,
                      dropdownColor: const Color(0xFF1A1F26),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Biome'),
                      items: [
                        for (final biome in Biome.values)
                          DropdownMenuItem(
                            value: biome,
                            child: Text(biome.displayName),
                          ),
                      ],
                      onChanged: (biome) {
                        if (biome != null) {
                          _updateDraft((d) => d.copyWith(biome: biome));
                        }
                      },
                    ),
                    DropdownButtonFormField<GameMode>(
                      initialValue: _draft.mode,
                      dropdownColor: const Color(0xFF1A1F26),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Mode'),
                      items: const [
                        DropdownMenuItem(
                          value: GameMode.waveDefense,
                          child: Text('Wave Defense'),
                        ),
                        DropdownMenuItem(
                          value: GameMode.skirmish,
                          child: Text('Skirmish'),
                        ),
                      ],
                      onChanged: (mode) {
                        if (mode == null) return;
                        _updateDraft(
                          (d) => d.copyWith(
                            mode: mode,
                            homeSites: mode == GameMode.skirmish
                                ? d.homeSites
                                : const [],
                          ),
                        );
                        if (mode != GameMode.skirmish &&
                            _tool == _EditorTool.homeSite) {
                          setState(() => _tool = _EditorTool.mountain);
                        }
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _widthController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Width',
                            ),
                            onSubmitted: (_) => _applyArenaSize(),
                            onEditingComplete: _applyArenaSize,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _heightController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Height',
                            ),
                            onSubmitted: (_) => _applyArenaSize(),
                            onEditingComplete: _applyArenaSize,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _startingGoldController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Starting gold',
                      ),
                      onSubmitted: (_) => _applyStartingGold(),
                      onEditingComplete: _applyStartingGold,
                    ),
                    const Divider(color: Colors.white24, height: 32),
                    _SectionLabel('Environment'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Dynamic weather over match',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: _draft.environment.dynamicWeather,
                      onChanged: (value) => _updateEnvironment(
                        (env) => env.copyWith(dynamicWeather: value),
                      ),
                    ),
                    Text(
                      'Sun angle: ${(_draft.environment.sunAngle * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Slider(
                      value: _draft.environment.sunAngle,
                      onChanged: (value) => _updateEnvironment(
                        (env) => env.copyWith(sunAngle: value),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preview weather at: ${(_previewProgress * 100).toStringAsFixed(0)}% of match',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Slider(
                      value: _previewProgress,
                      onChanged: (value) =>
                          setState(() => _previewProgress = value),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Weather timeline',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    for (final (index, keyframe)
                        in _draft.environment.timeline.indexed)
                      _WeatherKeyframeEditor(
                        keyframe: keyframe,
                        onChanged: (updated) =>
                            _replaceKeyframe(index, updated),
                        onRemove: () => _removeKeyframe(index),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addKeyframe,
                      icon: const Icon(Icons.add),
                      label: const Text('Add keyframe'),
                    ),
                  ],
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
    _regenDebounce?.cancel();
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _startingGoldController.dispose();
    _viewerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = _draft.name;
    _widthController.text = _draft.arenaWidth.toStringAsFixed(0);
    _heightController.text = _draft.arenaHeight.toStringAsFixed(0);
    _startingGoldController.text = _draft.startingGold.toString();
    _regenerate();
  }

  void _addKeyframe() {
    final timeline = _draft.environment.timeline;
    final nextProgress = timeline.isEmpty
        ? 0.0
        : (timeline.last.atProgress + 0.25).clamp(0.0, 1.0);
    _updateEnvironment(
      (env) => env.copyWith(
        timeline: [
          ...timeline,
          WeatherKeyframe(atProgress: nextProgress),
        ],
      ),
    );
  }

  void _applyArenaSize() {
    final width = double.tryParse(_widthController.text)?.clamp(200, 8000);
    final height = double.tryParse(_heightController.text)?.clamp(200, 8000);
    if (width == null || height == null) return;
    _updateDraft(
      (d) => d.copyWith(
        arenaWidth: width.toDouble(),
        arenaHeight: height.toDouble(),
      ),
    );
  }

  void _applyStartingGold() {
    final gold = int.tryParse(_startingGoldController.text)?.clamp(0, 100000);
    if (gold == null) return;
    _updateDraft((d) => d.copyWith(startingGold: gold));
  }

  void _handlePanEnd(DragEndDetails details) {
    final isWaterTool = _tool == _EditorTool.river || _tool == _EditorTool.lake;
    if (isWaterTool && _activeStroke.length >= 2) {
      final path = WaterPath(
        kind: _tool == _EditorTool.river
            ? WaterFeatureKind.river
            : WaterFeatureKind.lake,
        points: _activeStroke,
        width: _riverWidth,
      );
      _updateDraft((d) => d.copyWith(waterPaths: [...d.waterPaths, path]));
    }
    setState(() => _activeStroke = []);
  }

  void _handlePanStart(DragStartDetails details) {
    switch (_tool) {
      case _EditorTool.mountain:
      case _EditorTool.dune:
      case _EditorTool.erase:
        _paintAt(details.localPosition);
      case _EditorTool.river:
      case _EditorTool.lake:
        setState(() => _activeStroke = [_toWorld(details.localPosition)]);
      case _EditorTool.homeSite:
        _toggleHomeSiteAt(details.localPosition);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    switch (_tool) {
      case _EditorTool.mountain:
      case _EditorTool.dune:
      case _EditorTool.erase:
        _paintAt(details.localPosition);
      case _EditorTool.river:
      case _EditorTool.lake:
        setState(
          () => _activeStroke = [
            ..._activeStroke,
            _toWorld(details.localPosition),
          ],
        );
      case _EditorTool.homeSite:
        break; // single-tap placement only, handled in onPanStart
    }
  }

  void _paintAt(Offset local) {
    final preview = _preview;
    if (preview == null) return;
    final point = _toWorld(local);
    final grid = preview.grid;
    final col = (point.x / grid.cellSize).floor().clamp(0, grid.cols - 1);
    final row = (point.y / grid.cellSize).floor().clamp(0, grid.rows - 1);
    final kind = switch (_tool) {
      _EditorTool.mountain => ObstacleKind.mountain,
      _EditorTool.dune => ObstacleKind.dune,
      _EditorTool.erase => null,
      _EditorTool.river || _EditorTool.lake => null,
      _EditorTool.homeSite => null,
    };
    _updateDraft((d) {
      final cells = [...d.paintedCells]
        ..removeWhere((c) => c.col == col && c.row == row);
      if (kind != null) cells.add(PaintedCell(col: col, row: row, kind: kind));
      return d.copyWith(paintedCells: cells);
    });
  }

  /// Rasterizes the draft's current terrain and launches a real playthrough
  /// of it via the normal [GamePage] - home/spawn placement is fixed (east
  /// edge base, single western approach) since a draft doesn't carry
  /// [GameScene.homeSites]/layout data yet.
  Future<void> _play() async {
    setState(() => _playing = true);
    final preview = await _generator.generate(_draft);
    if (!mounted) return;
    setState(() => _playing = false);
    if (_draft.mode == GameMode.skirmish) {
      _showToast(
        'Testing as wave defense - skirmish playtesting is coming soon.',
        icon: Icons.info_outline,
      );
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GamePage(
          scene: GameScene(
            id: 'draft-${_draft.id}',
            name: _draft.name.isEmpty ? 'Untitled Map' : _draft.name,
            briefing: 'Testing your hand-drawn map draft.',
            biome: _draft.biome,
            waveCount: 5,
            startingGold: _draft.startingGold,
          ),
          terrainRepository: MapDraftTerrainRepository(
            draft: _draft,
            preview: preview,
          ),
        ),
      ),
    );
  }

  Future<void> _regenerate() async {
    final generation = ++_generation;
    final preview = await _generator.generate(_draft);
    if (!mounted || generation != _generation) return;
    setState(() => _preview = preview);
  }

  void _removeKeyframe(int index) {
    _updateEnvironment((env) {
      final timeline = [...env.timeline]..removeAt(index);
      return env.copyWith(timeline: timeline);
    });
  }

  void _replaceKeyframe(int index, WeatherKeyframe keyframe) {
    _updateEnvironment((env) {
      final timeline = [...env.timeline];
      timeline[index] = keyframe;
      return env.copyWith(timeline: timeline);
    });
  }

  void _resetZoom() {
    setState(() {
      _zoom = 1.0;
      _viewerController.value = Matrix4.identity();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _draftRepository.saveDraft(_draft);
    if (!mounted) return;
    setState(() => _saving = false);
    _showToast('Saved "${_draft.name}"');
  }

  /// Floats a brief glass-styled confirmation over the editor - matches the
  /// game's [showGlassMessage] look but is non-modal and auto-dismisses.
  void _showToast(String message, {IconData icon = Icons.check_circle}) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) =>
          _EditorToast(message: message, icon: icon, onDismissed: entry.remove),
    );
    overlay.insert(entry);
  }

  /// Places a new numbered home site at the tapped point, or removes an
  /// existing one if tapped near it - capped at [PlayerPalette.colors]'
  /// length since that's how many distinct player markers are supported.
  void _toggleHomeSiteAt(Offset local) {
    final point = _toWorld(local);
    const removeRadius = 32.0;
    final existingIndex = _draft.homeSites.indexWhere(
      (site) =>
          (site.x - point.x).abs() < removeRadius &&
          (site.y - point.y).abs() < removeRadius,
    );
    if (existingIndex == -1 &&
        _draft.homeSites.length >= PlayerPalette.colors.length) {
      _showToast(
        'Only ${PlayerPalette.colors.length} home sites supported',
        icon: Icons.info_outline,
      );
      return;
    }
    _updateDraft((d) {
      final sites = [...d.homeSites];
      if (existingIndex != -1) {
        sites.removeAt(existingIndex);
      } else {
        sites.add(point);
      }
      return d.copyWith(homeSites: sites);
    });
  }

  EditorPoint _toWorld(Offset local) {
    return EditorPoint(
      x: (local.dx / _canvasSize.width * _draft.arenaWidth).clamp(
        0,
        _draft.arenaWidth,
      ),
      y: (local.dy / _canvasSize.height * _draft.arenaHeight).clamp(
        0,
        _draft.arenaHeight,
      ),
    );
  }

  void _updateDraft(MapDraft Function(MapDraft) update) {
    setState(() => _draft = update(_draft));
    _regenDebounce?.cancel();
    _regenDebounce = Timer(const Duration(milliseconds: 250), _regenerate);
  }

  void _updateEnvironment(
    EnvironmentSettings Function(EnvironmentSettings) update,
  ) {
    _updateDraft((d) => d.copyWith(environment: update(d.environment)));
  }

  void _zoomBy(double factor) {
    setState(() {
      _zoom = (_zoom * factor).clamp(1.0, 4.0);
      _viewerController.value = Matrix4.identity()
        ..scaleByDouble(_zoom, _zoom, _zoom, 1);
    });
  }
}

class _MapEditorPainter extends CustomPainter {
  final EditorTerrainPreview? preview;
  final List<EditorPoint> activeStroke;
  final _EditorTool tool;
  final double arenaWidth;
  final double arenaHeight;
  final EnvironmentSettings environment;
  final double previewProgress;
  final List<EditorPoint> homeSites;

  _MapEditorPainter({
    required this.preview,
    required this.activeStroke,
    required this.tool,
    required this.arenaWidth,
    required this.arenaHeight,
    required this.environment,
    required this.previewProgress,
    required this.homeSites,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final palette = (preview?.biome ?? Biome.grassPlains).palette;
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

    final p = preview;
    if (p != null && p.grid.cols > 0 && p.grid.rows > 0) {
      final cellW = size.width / p.grid.cols;
      final cellH = size.height / p.grid.rows;
      for (var row = 0; row < p.grid.rows; row++) {
        for (var col = 0; col < p.grid.cols; col++) {
          final kind = p.obstacleKinds[row][col];
          if (kind == null) continue;
          canvas.drawRect(
            Rect.fromLTWH(col * cellW, row * cellH, cellW, cellH),
            Paint()..color = obstacleColor(kind, palette),
          );
        }
      }
      final gridPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..strokeWidth = 1;
      for (var col = 0; col <= p.grid.cols; col++) {
        canvas.drawLine(
          Offset(col * cellW, 0),
          Offset(col * cellW, size.height),
          gridPaint,
        );
      }
      for (var row = 0; row <= p.grid.rows; row++) {
        canvas.drawLine(
          Offset(0, row * cellH),
          Offset(size.width, row * cellH),
          gridPaint,
        );
      }
    }

    _paintSunLight(canvas, rect, size);
    _paintWeather(canvas, rect, size);
    _paintHomeSites(canvas, size);

    if (activeStroke.length >= 2) {
      final path = Path()
        ..moveTo(
          activeStroke[0].x / arenaWidth * size.width,
          activeStroke[0].y / arenaHeight * size.height,
        );
      for (final point in activeStroke.skip(1)) {
        path.lineTo(
          point.x / arenaWidth * size.width,
          point.y / arenaHeight * size.height,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color =
              (tool == _EditorTool.lake
                      ? Colors.blueAccent
                      : Colors.lightBlueAccent)
                  .withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MapEditorPainter oldDelegate) {
    return oldDelegate.preview != preview ||
        oldDelegate.activeStroke != activeStroke ||
        oldDelegate.tool != tool ||
        oldDelegate.arenaWidth != arenaWidth ||
        oldDelegate.arenaHeight != arenaHeight ||
        oldDelegate.environment != environment ||
        oldDelegate.previewProgress != previewProgress ||
        oldDelegate.homeSites != homeSites;
  }

  /// Draws each skirmish home site as a numbered, colored marker so a map
  /// author can see at a glance which player seat sits where - the same
  /// numbering/coloring the pre-game placement screen will use.
  void _paintHomeSites(Canvas canvas, Size size) {
    for (final (index, site) in homeSites.indexed) {
      final center = Offset(
        site.x / arenaWidth * size.width,
        site.y / arenaHeight * size.height,
      );
      paintHomeSiteMarker(canvas, center, index);
    }
  }

  /// Tints/dims the scene by sun height and adds raking light from whichever
  /// side the sun sits on - low angles (sunrise/sunset) look warm and
  /// high-contrast, overhead sun looks bright and neutral.
  void _paintSunLight(Canvas canvas, Rect rect, Size size) {
    final sunHeight = sin(environment.sunAngle * pi).clamp(0.0, 1.0);
    final sunFromRight = cos(environment.sunAngle * pi) >= 0;
    final warmTint = Color.lerp(
      const Color(0xFFFF8A3D),
      Colors.white,
      sunHeight,
    )!;

    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFF120A24)
            .withValues(alpha: (1 - sunHeight) * 0.4),
    );

    final from = sunFromRight ? Offset(size.width, 0) : Offset.zero;
    final to = sunFromRight ? Offset.zero : Offset(size.width, 0);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(from, to, [
          warmTint.withValues(alpha: 0.12 + (1 - sunHeight) * 0.28),
          Colors.transparent,
        ]),
    );
  }

  /// Samples the weather timeline at [previewProgress] and draws cloud/fog
  /// tinting plus simple rain/snow overlays so timeline edits are visible.
  void _paintWeather(Canvas canvas, Rect rect, Size size) {
    final weather = environment.sample(previewProgress);

    if (weather.cloudCover > 0) {
      canvas.drawRect(
        rect,
        Paint()
          ..color = const Color(0xFF37474F)
              .withValues(alpha: weather.cloudCover * 0.35),
      );
    }

    if (weather.fogDensity > 0) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [
            Colors.transparent,
            Colors.white.withValues(alpha: weather.fogDensity * 0.6),
          ]),
      );
    }

    if (weather.rainIntensity > 0) {
      final rnd = Random(7);
      final lean = weather.windStrength * 16;
      final paint = Paint()
        ..color = Colors.lightBlueAccent.withValues(alpha: 0.4)
        ..strokeWidth = 1.4;
      for (var i = 0; i < (weather.rainIntensity * 160).round(); i++) {
        final x = rnd.nextDouble() * size.width;
        final y = rnd.nextDouble() * size.height;
        canvas.drawLine(Offset(x, y), Offset(x + lean, y + 14), paint);
      }
    }

    if (weather.snowIntensity > 0) {
      final rnd = Random(9);
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);
      for (var i = 0; i < (weather.snowIntensity * 110).round(); i++) {
        final x = rnd.nextDouble() * size.width;
        final y = rnd.nextDouble() * size.height;
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _WeatherKeyframeEditor extends StatelessWidget {
  final WeatherKeyframe keyframe;
  final ValueChanged<WeatherKeyframe> onChanged;
  final VoidCallback onRemove;

  const _WeatherKeyframeEditor({
    required this.keyframe,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1F26),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'At ${(keyframe.atProgress * 100).toStringAsFixed(0)}% of match',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 18,
                  ),
                  onPressed: onRemove,
                ),
              ],
            ),
            _keyframeSlider(
              'Wind',
              keyframe.windStrength,
              (v) => onChanged(keyframe.copyWith(windStrength: v)),
            ),
            _keyframeSlider(
              'Rain',
              keyframe.rainIntensity,
              (v) => onChanged(keyframe.copyWith(rainIntensity: v)),
            ),
            _keyframeSlider(
              'Snow',
              keyframe.snowIntensity,
              (v) => onChanged(keyframe.copyWith(snowIntensity: v)),
            ),
            _keyframeSlider(
              'Fog',
              keyframe.fogDensity,
              (v) => onChanged(keyframe.copyWith(fogDensity: v)),
            ),
            _keyframeSlider(
              'Cloud',
              keyframe.cloudCover,
              (v) => onChanged(keyframe.copyWith(cloudCover: v)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keyframeSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        Expanded(
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}

extension on _EditorTool {
  String get label => switch (this) {
    _EditorTool.mountain => 'Mountain',
    _EditorTool.dune => 'Dune',
    _EditorTool.erase => 'Erase',
    _EditorTool.river => 'River',
    _EditorTool.lake => 'Lake',
    _EditorTool.homeSite => 'Home',
  };
}
