import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/combat/unit_kind.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/routes.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../game_core/presentation/home_site_marker_painter.dart';
import '../../game_core/presentation/player_palette.dart';
import '../../terrain/domain/models/biome.dart';
import '../../terrain/domain/models/obstacle_kind.dart';
import '../../terrain/presentation/obstacle_color.dart';
import '../../waves/domain/models/wave_loadout.dart';
import '../../waves/impl/wave_loadout_generator.dart';
import '../../waves/impl/wave_repository_impl.dart';
import '../domain/models/editor_point.dart';
import '../domain/models/editor_terrain_preview.dart';
import '../domain/models/environment_settings.dart';
import '../domain/models/map_draft.dart';
import '../domain/models/painted_cell.dart';
import '../domain/models/water_path.dart';
import '../domain/models/weather_keyframe.dart';
import '../domain/repos/map_draft_repository.dart';
import '../impl/draft_wave_repository.dart';
import '../impl/editor_terrain_generator.dart';
import '../impl/map_draft_terrain_repository.dart';

/// Wave Defense has exactly one player base; Skirmish supports up to one
/// per [PlayerPalette] slot.
int _maxHomeSites(GameMode mode) =>
    mode == GameMode.skirmish ? PlayerPalette.colors.length : 1;

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
  final _waveCountController = TextEditingController();

  late final _MapEditorState _state = _MapEditorState(widget.initialDraft);
  Size _canvasSize = const Size(900, 540);
  Timer? _regenDebounce;
  int _generation = 0;

  /// Zoom applied to the canvas viewport only - doesn't affect the draft.
  final _viewerController = TransformationController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state.listenable,
      builder: (context, _) {
        final currentDraft = _state.draft.value;
        final currentPreview = _state.preview.value;
        final currentTool = _state.tool.value;
        final currentRiverWidth = _state.riverWidth.value;
        final currentSelectedWave = _state.selectedWaveNumber.value;
        final currentStroke = _state.activeStroke.value;
        final currentSaving = _state.saving.value;
        final currentPlaying = _state.playing.value;
        final currentDownloading = _state.downloading.value;
        final currentUploading = _state.uploading.value;
        final currentZoom = _state.zoom.value;
        final currentPreviewProgress = _state.previewProgress.value;
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E14),
          appBar: AppBar(
            backgroundColor: const Color(0xFF11161D),
            title: TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (value) =>
                  _updateDraft((d) => d.copyWith(name: value)),
            ),
            actions: [
              _EditorAppBarButton(
                icon: Icons.play_arrow,
                label: 'Play',
                color: Colors.lightGreenAccent,
                loading: currentPlaying,
                onPressed: currentPlaying ? null : _play,
              ),
              _EditorAppBarButton(
                icon: Icons.save,
                label: 'Save',
                color: Colors.cyanAccent,
                loading: currentSaving,
                onPressed: currentSaving ? null : _save,
              ),
              _EditorAppBarButton(
                icon: Icons.download,
                label: 'Download',
                color: Colors.amberAccent,
                loading: currentDownloading,
                onPressed: currentDownloading ? null : _downloadDraft,
              ),
              _EditorAppBarButton(
                icon: Icons.upload,
                label: 'Upload',
                color: Colors.amberAccent,
                loading: currentUploading,
                onPressed: currentUploading ? null : _uploadDraft,
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
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.white70,
                            ),
                            onPressed: () => _zoomBy(1 / 1.25),
                          ),
                          Text(
                            '${(currentZoom * 100).round()}%',
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
                              final aspect =
                                  currentDraft.arenaWidth /
                                  currentDraft.arenaHeight;
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
                                        event.scrollDelta.dy < 0
                                            ? 1.1
                                            : 1 / 1.1,
                                      );
                                    }
                                  },
                                  child: InteractiveViewer(
                                    transformationController: _viewerController,
                                    panEnabled: false,
                                    scaleEnabled: true,
                                    minScale: 1,
                                    maxScale: 4,
                                    onInteractionEnd: (_) => _state.setZoom(
                                      _viewerController.value
                                          .getMaxScaleOnAxis(),
                                    ),
                                    child: GestureDetector(
                                      onPanStart: _handlePanStart,
                                      onPanUpdate: _handlePanUpdate,
                                      onPanEnd: _handlePanEnd,
                                      child: CustomPaint(
                                        size: _canvasSize,
                                        painter: _MapEditorPainter(
                                          preview: currentPreview,
                                          activeStroke: currentStroke,
                                          tool: currentTool,
                                          arenaWidth: currentDraft.arenaWidth,
                                          arenaHeight: currentDraft.arenaHeight,
                                          environment: currentDraft.environment,
                                          previewProgress:
                                              currentPreviewProgress,
                                          homeSites: currentDraft.homeSites,
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
                              ChoiceChip(
                                label: Text(tool.label),
                                selected: currentTool == tool,
                                onSelected: (_) => _state.setTool(tool),
                              ),
                          ],
                        ),
                        if (currentTool == _EditorTool.homeSite) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Home sites: ${currentDraft.homeSites.length}/'
                            '${_maxHomeSites(currentDraft.mode)} - tap to '
                            'place, tap a marker to remove.',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (currentTool == _EditorTool.river) ...[
                          const SizedBox(height: 8),
                          Text(
                            'River width: ${currentRiverWidth.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Slider(
                            value: currentRiverWidth,
                            min: 16,
                            max: 160,
                            onChanged: (value) => _state.setRiverWidth(value),
                          ),
                        ],
                        const Divider(color: Colors.white24, height: 32),
                        _SectionLabel('Map'),
                        DropdownButtonFormField<Biome>(
                          initialValue: currentDraft.biome,
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
                          initialValue: currentDraft.mode,
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
                                homeSites: d.homeSites
                                    .take(_maxHomeSites(mode))
                                    .toList(),
                              ),
                            );
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
                        if (currentDraft.mode == GameMode.waveDefense) ...[
                          const Divider(color: Colors.white24, height: 32),
                          _SectionLabel('Waves'),
                          TextField(
                            controller: _waveCountController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Number of waves',
                            ),
                            onSubmitted: (_) => _applyWaveCount(),
                            onEditingComplete: _applyWaveCount,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _randomizeAllWaves,
                            icon: const Icon(Icons.shuffle),
                            label: Text(
                              'Randomize all ${currentDraft.waveCount} waves',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Previous wave',
                                icon: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white70,
                                ),
                                onPressed: currentSelectedWave > 1
                                    ? () => _state.setSelectedWaveNumber(
                                        currentSelectedWave - 1,
                                      )
                                    : null,
                              ),
                              Expanded(
                                child: Text(
                                  'Wave $currentSelectedWave / ${currentDraft.waveCount}'
                                  '${_hasCustomLoadout(currentSelectedWave) ? '' : ' (auto)'}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Next wave',
                                icon: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                ),
                                onPressed:
                                    currentSelectedWave < currentDraft.waveCount
                                    ? () => _state.setSelectedWaveNumber(
                                        currentSelectedWave + 1,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                          for (final kind in UnitKind.values)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      kind.name,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Fewer',
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.white54,
                                    ),
                                    onPressed: () => _setWaveUnitCount(
                                      kind,
                                      _currentLoadout().countOf(kind) - 1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 28,
                                    child: Text(
                                      '${_currentLoadout().countOf(kind)}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'More',
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.white54,
                                    ),
                                    onPressed: () => _setWaveUnitCount(
                                      kind,
                                      _currentLoadout().countOf(kind) + 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _randomizeSelectedWave,
                                  icon: const Icon(Icons.casino),
                                  label: const Text('Randomize'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _clearSelectedWave,
                                  icon: const Icon(Icons.restore),
                                  label: const Text('Reset to auto'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(color: Colors.white24, height: 32),
                        _SectionLabel('Environment'),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Dynamic weather over match',
                            style: TextStyle(color: Colors.white70),
                          ),
                          value: currentDraft.environment.dynamicWeather,
                          onChanged: (value) => _updateEnvironment(
                            (env) => env.copyWith(dynamicWeather: value),
                          ),
                        ),
                        Text(
                          'Sun angle: ${(currentDraft.environment.sunAngle * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Slider(
                          value: currentDraft.environment.sunAngle,
                          onChanged: (value) => _updateEnvironment(
                            (env) => env.copyWith(sunAngle: value),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Preview weather at: ${(currentPreviewProgress * 100).toStringAsFixed(0)}% of match',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Slider(
                          value: currentPreviewProgress,
                          onChanged: (value) =>
                              _state.setPreviewProgress(value),
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
                            in currentDraft.environment.timeline.indexed)
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
      },
    );
  }

  @override
  void dispose() {
    _regenDebounce?.cancel();
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _startingGoldController.dispose();
    _waveCountController.dispose();
    _viewerController.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _nameController.text = draft.name;
    _widthController.text = draft.arenaWidth.toStringAsFixed(0);
    _heightController.text = draft.arenaHeight.toStringAsFixed(0);
    _startingGoldController.text = draft.startingGold.toString();
    _waveCountController.text = draft.waveCount.toString();
    _regenerate();
  }

  void _addKeyframe() {
    final timeline = _state.draft.value.environment.timeline;
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

  void _applyWaveCount() {
    final count = int.tryParse(_waveCountController.text)?.clamp(1, 200);
    if (count == null) return;
    _updateDraft((d) => d.copyWith(waveCount: count));
    if (_state.selectedWaveNumber.value > count) {
      _state.setSelectedWaveNumber(count);
    }
  }

  void _clearSelectedWave() {
    _replaceLoadout(WaveLoadout(waveNumber: _state.selectedWaveNumber.value));
  }

  WaveLoadout _currentLoadout() => _loadoutFor(_state.selectedWaveNumber.value);

  /// Exports the current draft as a standalone `.json` file the player can
  /// back up, share, or hand-edit - opens the platform's native save/
  /// download dialog (a browser download on web, a save-as dialog on
  /// desktop).
  Future<void> _downloadDraft() async {
    _state.setDownloading(true);
    try {
      final draft = _state.draft.value;
      final bytes = Uint8List.fromList(
        utf8.encode(const JsonEncoder.withIndent('  ').convert(draft.toJson())),
      );
      final safeName = draft.name.trim().isEmpty ? 'map' : draft.name.trim();
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Download map',
        fileName: '$safeName.json',
        bytes: bytes,
        mimeType: 'application/json',
      );
      if (!mounted) return;
      if (saved != null) _showToast('Downloaded "${draft.name}"');
    } finally {
      if (mounted) _state.setDownloading(false);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    final tool = _state.tool.value;
    final stroke = _state.activeStroke.value;
    final isWaterTool = tool == _EditorTool.river || tool == _EditorTool.lake;
    if (isWaterTool && stroke.length >= 2) {
      final path = WaterPath(
        kind: tool == _EditorTool.river
            ? WaterFeatureKind.river
            : WaterFeatureKind.lake,
        points: stroke,
        width: _state.riverWidth.value,
      );
      _updateDraft((d) => d.copyWith(waterPaths: [...d.waterPaths, path]));
    }
    _state.setActiveStroke(const []);
  }

  void _handlePanStart(DragStartDetails details) {
    switch (_state.tool.value) {
      case _EditorTool.mountain:
      case _EditorTool.dune:
      case _EditorTool.erase:
        _paintAt(details.localPosition);
      case _EditorTool.river:
      case _EditorTool.lake:
        _state.setActiveStroke([_toWorld(details.localPosition)]);
      case _EditorTool.homeSite:
        _toggleHomeSiteAt(details.localPosition);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    switch (_state.tool.value) {
      case _EditorTool.mountain:
      case _EditorTool.dune:
      case _EditorTool.erase:
        _paintAt(details.localPosition);
      case _EditorTool.river:
      case _EditorTool.lake:
        _state.setActiveStroke([
          ..._state.activeStroke.value,
          _toWorld(details.localPosition),
        ]);
      case _EditorTool.homeSite:
        break; // single-tap placement only, handled in onPanStart
    }
  }

  bool _hasCustomLoadout(int waveNumber) =>
      _loadoutFor(waveNumber).unitCounts.isNotEmpty;

  WaveLoadout _loadoutFor(int waveNumber) {
    for (final loadout in _state.draft.value.waveLoadouts) {
      if (loadout.waveNumber == waveNumber) return loadout;
    }
    return WaveLoadout(waveNumber: waveNumber);
  }

  void _paintAt(Offset local) {
    final preview = _state.preview.value;
    if (preview == null) return;
    final point = _toWorld(local);
    final grid = preview.grid;
    final col = (point.x / grid.cellSize).floor().clamp(0, grid.cols - 1);
    final row = (point.y / grid.cellSize).floor().clamp(0, grid.rows - 1);
    final kind = switch (_state.tool.value) {
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
  /// of it via the normal [GamePage] - the base lands at the editor's placed
  /// home site if one was set (falls back to the default east-edge base,
  /// single western approach, otherwise).
  Future<void> _play() async {
    _state.setPlaying(true);
    final draft = _state.draft.value;
    final preview = await _generator.generate(draft);
    if (!mounted) return;
    _state.setPlaying(false);
    if (draft.mode == GameMode.skirmish) {
      _showToast(
        'Testing as wave defense - skirmish playtesting is coming soon.',
        icon: Icons.info_outline,
      );
    }
    await context.push(
      Routes.game.route,
      extra: GameRouteArgs(
        scene: GameScene(
          id: 'draft-${draft.id}',
          name: draft.name.isEmpty ? 'Untitled Map' : draft.name,
          briefing: 'Testing your hand-drawn map draft.',
          biome: draft.biome,
          waveCount: draft.waveCount,
          startingGold: draft.startingGold,
        ),
        terrainRepository: MapDraftTerrainRepository(
          draft: draft,
          preview: preview,
          humanBaseSite: draft.homeSites.isNotEmpty
              ? draft.homeSites.first
              : null,
        ),
        waveRepository: DraftWaveRepository(
          loadouts: draft.waveLoadouts,
          totalWaves: draft.waveCount,
          fallback: WaveRepositoryImpl(
            totalWaves: draft.waveCount,
            biome: draft.biome,
          ),
        ),
      ),
    );
  }

  void _randomizeAllWaves() {
    _updateDraft(
      (d) =>
          d.copyWith(waveLoadouts: WaveLoadoutGenerator.randomize(d.waveCount)),
    );
  }

  void _randomizeSelectedWave() {
    _replaceLoadout(
      WaveLoadoutGenerator.randomizeWave(_state.selectedWaveNumber.value),
    );
  }

  Future<void> _regenerate() async {
    final generation = ++_generation;
    final preview = await _generator.generate(_state.draft.value);
    if (!mounted || generation != _generation) return;
    _state.setPreview(preview);
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

  void _replaceLoadout(WaveLoadout loadout) {
    _updateDraft((d) {
      final loadouts = [...d.waveLoadouts]
        ..removeWhere((l) => l.waveNumber == loadout.waveNumber);
      if (loadout.unitCounts.isNotEmpty) loadouts.add(loadout);
      return d.copyWith(waveLoadouts: loadouts);
    });
  }

  void _resetZoom() {
    _state.setZoom(1.0);
    _viewerController.value = Matrix4.identity();
  }

  Future<void> _save() async {
    _state.setSaving(true);
    final draft = _state.draft.value;
    await _draftRepository.saveDraft(draft);
    if (!mounted) return;
    _state.setSaving(false);
    _showToast('Saved "${draft.name}"');
  }

  void _setWaveUnitCount(UnitKind kind, int count) {
    _replaceLoadout(_currentLoadout().withCount(kind, count.clamp(0, 999)));
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
  /// existing one if tapped near it. Wave Defense only ever has a single
  /// player base, so it's capped at 1; Skirmish allows one per
  /// [PlayerPalette.colors] slot.
  void _toggleHomeSiteAt(Offset local) {
    final point = _toWorld(local);
    const removeRadius = 32.0;
    final draft = _state.draft.value;
    final existingIndex = draft.homeSites.indexWhere(
      (site) =>
          (site.x - point.x).abs() < removeRadius &&
          (site.y - point.y).abs() < removeRadius,
    );
    final maxSites = _maxHomeSites(draft.mode);
    if (existingIndex == -1 && draft.homeSites.length >= maxSites) {
      _showToast(
        'Only $maxSites home sites supported',
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
    final draft = _state.draft.value;
    return EditorPoint(
      x: (local.dx / _canvasSize.width * draft.arenaWidth).clamp(
        0,
        draft.arenaWidth,
      ),
      y: (local.dy / _canvasSize.height * draft.arenaHeight).clamp(
        0,
        draft.arenaHeight,
      ),
    );
  }

  void _updateDraft(MapDraft Function(MapDraft) update) {
    _state.setDraft(update(_state.draft.value));
    _regenDebounce?.cancel();
    _regenDebounce = Timer(const Duration(milliseconds: 250), _regenerate);
  }

  void _updateEnvironment(
    EnvironmentSettings Function(EnvironmentSettings) update,
  ) {
    _updateDraft((d) => d.copyWith(environment: update(d.environment)));
  }

  /// Imports a previously-downloaded `.json` map file, replacing the
  /// editor's current draft contents in place (the draft keeps its id, so
  /// Save continues to overwrite the same slot it was opened from).
  Future<void> _uploadDraft() async {
    _state.setUploading(true);
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: 'Upload map',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final imported = MapDraft.fromJson(json)
          .copyWith(id: _state.draft.value.id);
      _state.setDraft(imported);
      _nameController.text = imported.name;
      _widthController.text = imported.arenaWidth.toStringAsFixed(0);
      _heightController.text = imported.arenaHeight.toStringAsFixed(0);
      _startingGoldController.text = imported.startingGold.toString();
      _waveCountController.text = imported.waveCount.toString();
      await _regenerate();
      if (!mounted) return;
      _showToast('Imported "${imported.name}"');
    } catch (_) {
      if (mounted) {
        _showToast(
          'Could not read that file as a map',
          icon: Icons.error_outline,
        );
      }
    } finally {
      if (mounted) _state.setUploading(false);
    }
  }

  void _zoomBy(double factor) {
    final next = (_state.zoom.value * factor).clamp(1.0, 4.0);
    _state.setZoom(next);
    _viewerController.value = Matrix4.identity()
      ..scaleByDouble(next, next, next, 1);
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

/// Page-owned state for [MapEditorPage]: every mutable piece of editor UI
/// state (the draft itself, its live terrain preview, brush selection,
/// in-progress stroke, wave being edited, and save/play/upload/download
/// busy flags) lives here as private [ValueNotifier]s with read-only
/// [ValueListenable] getters - instantiated and disposed by the page's own
/// State, not shared anywhere else.
class _MapEditorState {
  final ValueNotifier<MapDraft> _draft;
  final ValueNotifier<EditorTerrainPreview?> _preview = ValueNotifier(null);
  final ValueNotifier<_EditorTool> _tool = ValueNotifier(_EditorTool.mountain);
  final ValueNotifier<double> _riverWidth = ValueNotifier(48);
  final ValueNotifier<int> _selectedWaveNumber = ValueNotifier(1);
  final ValueNotifier<List<EditorPoint>> _activeStroke = ValueNotifier(
    const [],
  );
  final ValueNotifier<bool> _saving = ValueNotifier(false);
  final ValueNotifier<bool> _playing = ValueNotifier(false);
  final ValueNotifier<bool> _downloading = ValueNotifier(false);
  final ValueNotifier<bool> _uploading = ValueNotifier(false);
  final ValueNotifier<double> _zoom = ValueNotifier(1.0);
  final ValueNotifier<double> _previewProgress = ValueNotifier(0.0);

  _MapEditorState(MapDraft initialDraft) : _draft = ValueNotifier(initialDraft);

  ValueListenable<List<EditorPoint>> get activeStroke => _activeStroke;
  ValueListenable<bool> get downloading => _downloading;
  ValueListenable<MapDraft> get draft => _draft;

  /// A single [Listenable] combining every notifier above, so the page can
  /// rebuild its whole (tightly-coupled) editor tree from one listener
  /// instead of nesting a builder per field.
  Listenable get listenable => Listenable.merge([
    _draft,
    _preview,
    _tool,
    _riverWidth,
    _selectedWaveNumber,
    _activeStroke,
    _saving,
    _playing,
    _downloading,
    _uploading,
    _zoom,
    _previewProgress,
  ]);
  ValueListenable<bool> get playing => _playing;
  ValueListenable<EditorTerrainPreview?> get preview => _preview;
  ValueListenable<double> get previewProgress => _previewProgress;
  ValueListenable<double> get riverWidth => _riverWidth;
  ValueListenable<bool> get saving => _saving;
  ValueListenable<int> get selectedWaveNumber => _selectedWaveNumber;
  ValueListenable<_EditorTool> get tool => _tool;
  ValueListenable<bool> get uploading => _uploading;

  ValueListenable<double> get zoom => _zoom;

  void dispose() {
    _draft.dispose();
    _preview.dispose();
    _tool.dispose();
    _riverWidth.dispose();
    _selectedWaveNumber.dispose();
    _activeStroke.dispose();
    _saving.dispose();
    _playing.dispose();
    _downloading.dispose();
    _uploading.dispose();
    _zoom.dispose();
    _previewProgress.dispose();
  }

  void setActiveStroke(List<EditorPoint> value) => _activeStroke.value = value;
  void setDownloading(bool value) => _downloading.value = value;
  void setDraft(MapDraft value) => _draft.value = value;
  void setPlaying(bool value) => _playing.value = value;
  void setPreview(EditorTerrainPreview? value) => _preview.value = value;
  void setPreviewProgress(double value) => _previewProgress.value = value;
  void setRiverWidth(double value) => _riverWidth.value = value;
  void setSaving(bool value) => _saving.value = value;
  void setSelectedWaveNumber(int value) => _selectedWaveNumber.value = value;
  void setTool(_EditorTool value) => _tool.value = value;
  void setUploading(bool value) => _uploading.value = value;

  void setZoom(double value) => _zoom.value = value;
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
