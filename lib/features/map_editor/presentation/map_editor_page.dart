import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/combat/unit_kind.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/routes.dart';
import '../../../generated/l10n.dart';
import '../../../theme/app_theme/app_theme_colors.dart';
import '../../../theme/app_theme/app_theme_paddings.dart';
import '../../../theme/app_theme/app_theme_spacing.dart';
import '../../game_core/domain/models/game_scene.dart';
import '../../terrain/domain/models/biome.dart';
import '../../terrain/extensions/biome_extensions.dart';
import '../domain/models/map_draft.dart';
import '../domain/repos/map_draft_repository.dart';
import '../extensions/editor_tool_extensions.dart';
import 'state/map_editor_draft_state.dart';
import 'state/map_editor_persistence_state.dart';
import 'widgets/map_editor_app_bar_button_widget.dart';
import 'widgets/map_editor_canvas_painter.dart';
import 'widgets/map_editor_section_label_widget.dart';
import 'widgets/map_editor_toast_widget.dart';
import 'widgets/map_editor_weather_keyframe_editor_widget.dart';

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

class _MapEditorPageState extends State<MapEditorPage> {
  final _nameController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _startingGoldController = TextEditingController();
  final _waveCountController = TextEditingController();

  late final MapEditorDraftState _draftState;
  late final MapEditorPersistenceState _persistenceState;
  Size _canvasSize = const Size(900, 540);

  /// Zoom applied to the canvas viewport only - doesn't affect the draft.
  final _viewerController = TransformationController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _draftState.listenable,
        _persistenceState.saving,
        _persistenceState.playing,
        _persistenceState.downloading,
        _persistenceState.uploading,
      ]),
      builder: (context, _) {
        final currentDraft = _draftState.draft.value;
        final currentPreview = _draftState.preview.value;
        final currentTool = _draftState.tool.value;
        final currentRiverWidth = _draftState.riverWidth.value;
        final currentSelectedWave = _draftState.selectedWaveNumber.value;
        final currentStroke = _draftState.activeStroke.value;
        final currentSaving = _persistenceState.saving.value;
        final currentPlaying = _persistenceState.playing.value;
        final currentDownloading = _persistenceState.downloading.value;
        final currentUploading = _persistenceState.uploading.value;
        final currentZoom = _draftState.zoom.value;
        final currentPreviewProgress = _draftState.previewProgress.value;
        return Scaffold(
          backgroundColor: AppThemeColors.background,
          appBar: AppBar(
            backgroundColor: AppThemeColors.gradientPanelEnd,
            title: TextField(
              controller: _nameController,
              style: const TextStyle(
                color: AppThemeColors.textPrimary,
                fontSize: 18,
              ),
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (value) => _draftState.setName(value),
            ),
            actions: [
              MapEditorAppBarButtonWidget(
                icon: Icons.play_arrow,
                label: S.current.playLabelEditorPage,
                color: AppThemeColors.accentLightGreen,
                loading: currentPlaying,
                onPressed: currentPlaying ? null : _play,
              ),
              MapEditorAppBarButtonWidget(
                icon: Icons.save,
                label: S.current.saveLabelEditorPage,
                color: AppThemeColors.accentCyan,
                loading: currentSaving,
                onPressed: currentSaving ? null : _save,
              ),
              MapEditorAppBarButtonWidget(
                icon: Icons.download,
                label: S.current.downloadLabelEditorPage,
                color: AppThemeColors.accentAmber,
                loading: currentDownloading,
                onPressed: currentDownloading ? null : _downloadDraft,
              ),
              MapEditorAppBarButtonWidget(
                icon: Icons.upload,
                label: S.current.uploadLabelEditorPage,
                color: AppThemeColors.accentAmber,
                loading: currentUploading,
                onPressed: currentUploading ? null : _uploadDraft,
              ),
              SizedBox(width: AppThemeSpacing.space12),
            ],
          ),
          body: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: AppThemePaddings.ltrb16_8_16_0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: S.current.zoomOutTooltipEditorPage,
                            icon: const Icon(
                              Icons.remove,
                              color: AppThemeColors.textMuted,
                            ),
                            onPressed: () => _zoomBy(1 / 1.25),
                          ),
                          Text(
                            S.current.zoomPercentEditorPage(
                              (currentZoom * 100).round(),
                            ),
                            style: const TextStyle(color: AppThemeColors.textMuted),
                          ),
                          IconButton(
                            tooltip: S.current.zoomInTooltipEditorPage,
                            icon: const Icon(
                              Icons.add,
                              color: AppThemeColors.textMuted,
                            ),
                            onPressed: () => _zoomBy(1.25),
                          ),
                          IconButton(
                            tooltip: S.current.resetZoomTooltipEditorPage,
                            icon: const Icon(
                              Icons.center_focus_weak,
                              color: AppThemeColors.textMuted,
                            ),
                            onPressed: _resetZoom,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: AppThemePaddings.all24,
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
                                    color: AppThemeColors.borderSubtle,
                                    width: 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppThemeColors.scrimSubtle,
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
                                    onInteractionEnd: (_) =>
                                        _draftState.setZoom(
                                          _viewerController.value
                                              .getMaxScaleOnAxis(),
                                        ),
                                    child: GestureDetector(
                                      onPanStart: (d) =>
                                          _draftState.handlePanStart(
                                            d.localPosition,
                                            _canvasSize,
                                          ),
                                      onPanUpdate: (d) =>
                                          _draftState.handlePanUpdate(
                                            d.localPosition,
                                            _canvasSize,
                                          ),
                                      onPanEnd: (_) =>
                                          _draftState.handlePanEnd(),
                                      child: CustomPaint(
                                        size: _canvasSize,
                                        painter: MapEditorCanvasPainter(
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
                padding: AppThemePaddings.ltrb0_16_16_16,
                child: SizedBox(
                  width: 320,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppThemeColors.gradientPanelEnd,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppThemeColors.borderSubtle,
                        width: 1.5,
                      ),
                    ),
                    child: ListView(
                      padding: AppThemePaddings.all16,
                      children: [
                        MapEditorSectionLabelWidget(
                          S.current.brushLabelEditorPage,
                        ),
                        Wrap(
                          spacing: AppThemeSpacing.space8,
                          runSpacing: AppThemeSpacing.space8,
                          children: [
                            for (final tool in EditorTool.values)
                              ChoiceChip(
                                label: Text(tool.label),
                                selected: currentTool == tool,
                                onSelected: (_) => _draftState.setTool(tool),
                              ),
                          ],
                        ),
                        if (currentTool == EditorTool.homeSite) ...[
                          SizedBox(height: AppThemeSpacing.space8),
                          Text(
                            S.current.homeSitesHintEditorPage(
                              currentDraft.homeSites.length,
                              _draftState.maxHomeSites,
                            ),
                            style: const TextStyle(
                              color: AppThemeColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (currentTool == EditorTool.river) ...[
                          SizedBox(height: AppThemeSpacing.space8),
                          Text(
                            S.current.riverWidthLabelEditorPage(
                              currentRiverWidth.round(),
                            ),
                            style: const TextStyle(color: AppThemeColors.textMuted),
                          ),
                          Slider(
                            value: currentRiverWidth,
                            min: 16,
                            max: 160,
                            onChanged: (value) =>
                                _draftState.setRiverWidth(value),
                          ),
                        ],
                        const Divider(
                          color: AppThemeColors.borderSubtle,
                          height: 32,
                        ),
                        MapEditorSectionLabelWidget(
                          S.current.mapLabelEditorPage,
                        ),
                        DropdownButtonFormField<Biome>(
                          initialValue: currentDraft.biome,
                          dropdownColor: AppThemeColors.surfacePanel,
                          style: const TextStyle(color: AppThemeColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: S.current.biomeLabelEditorPage,
                          ),
                          items: [
                            for (final biome in Biome.values)
                              DropdownMenuItem(
                                value: biome,
                                child: Text(biome.displayName),
                              ),
                          ],
                          onChanged: (biome) {
                            if (biome != null) _draftState.setBiome(biome);
                          },
                        ),
                        DropdownButtonFormField<GameMode>(
                          initialValue: currentDraft.mode,
                          dropdownColor: AppThemeColors.surfacePanel,
                          style: const TextStyle(color: AppThemeColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: S.current.modeLabelEditorPage,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: GameMode.waveDefense,
                              child: Text(
                                S.current.waveDefenseOptionEditorPage,
                              ),
                            ),
                            DropdownMenuItem(
                              value: GameMode.skirmish,
                              child: Text(S.current.skirmishOptionEditorPage),
                            ),
                          ],
                          onChanged: (mode) {
                            if (mode != null) _draftState.setMode(mode);
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _widthController,
                                style: const TextStyle(color: AppThemeColors.textPrimary),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: S.current.widthLabelEditorPage,
                                ),
                                onSubmitted: (_) => _applyArenaSize(),
                                onEditingComplete: _applyArenaSize,
                              ),
                            ),
                            SizedBox(width: AppThemeSpacing.space12),
                            Expanded(
                              child: TextField(
                                controller: _heightController,
                                style: const TextStyle(color: AppThemeColors.textPrimary),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: S.current.heightLabelEditorPage,
                                ),
                                onSubmitted: (_) => _applyArenaSize(),
                                onEditingComplete: _applyArenaSize,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppThemeSpacing.space12),
                        TextField(
                          controller: _startingGoldController,
                          style: const TextStyle(color: AppThemeColors.textPrimary),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: S.current.startingGoldLabelEditorPage,
                          ),
                          onSubmitted: (_) => _applyStartingGold(),
                          onEditingComplete: _applyStartingGold,
                        ),
                        if (currentDraft.mode == GameMode.waveDefense) ...[
                          const Divider(
                            color: AppThemeColors.borderSubtle,
                            height: 32,
                          ),
                          MapEditorSectionLabelWidget(
                            S.current.wavesLabelEditorPage,
                          ),
                          TextField(
                            controller: _waveCountController,
                            style: const TextStyle(color: AppThemeColors.textPrimary),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: S.current.waveCountLabelEditorPage,
                            ),
                            onSubmitted: (_) => _applyWaveCount(),
                            onEditingComplete: _applyWaveCount,
                          ),
                          SizedBox(height: AppThemeSpacing.space8),
                          OutlinedButton.icon(
                            onPressed: _draftState.randomizeAllWaves,
                            icon: const Icon(Icons.shuffle),
                            label: Text(
                              S.current.randomizeAllWavesLabelEditorPage(
                                currentDraft.waveCount,
                              ),
                            ),
                          ),
                          SizedBox(height: AppThemeSpacing.space12),
                          Row(
                            children: [
                              IconButton(
                                tooltip:
                                    S.current.previousWaveTooltipEditorPage,
                                icon: const Icon(
                                  Icons.chevron_left,
                                  color: AppThemeColors.textMuted,
                                ),
                                onPressed: currentSelectedWave > 1
                                    ? () => _draftState.setSelectedWaveNumber(
                                        currentSelectedWave - 1,
                                      )
                                    : null,
                              ),
                              Expanded(
                                child: Text(
                                  S.current.waveHeaderEditorPage(
                                        currentSelectedWave,
                                        currentDraft.waveCount,
                                      ) +
                                      (_draftState.hasCustomLoadout(
                                            currentSelectedWave,
                                          )
                                          ? ''
                                          : S.current.autoSuffixEditorPage),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppThemeColors.textMuted),
                                ),
                              ),
                              IconButton(
                                tooltip: S.current.nextWaveTooltipEditorPage,
                                icon: const Icon(
                                  Icons.chevron_right,
                                  color: AppThemeColors.textMuted,
                                ),
                                onPressed:
                                    currentSelectedWave < currentDraft.waveCount
                                    ? () => _draftState.setSelectedWaveNumber(
                                        currentSelectedWave + 1,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                          for (final kind in UnitKind.values)
                            Padding(
                              padding: AppThemePaddings.v2,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      kind.name,
                                      style: const TextStyle(
                                        color: AppThemeColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: S.current.fewerTooltipEditorPage,
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: AppThemeColors.textSecondary,
                                    ),
                                    onPressed: () =>
                                        _draftState.setWaveUnitCount(
                                          kind,
                                          _draftState.currentLoadout.countOf(
                                                kind,
                                              ) -
                                              1,
                                        ),
                                  ),
                                  SizedBox(
                                    width: 28,
                                    child: Text(
                                      '${_draftState.currentLoadout.countOf(kind)}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppThemeColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: S.current.moreTooltipEditorPage,
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: AppThemeColors.textSecondary,
                                    ),
                                    onPressed: () =>
                                        _draftState.setWaveUnitCount(
                                          kind,
                                          _draftState.currentLoadout.countOf(
                                                kind,
                                              ) +
                                              1,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _draftState.randomizeSelectedWave,
                                  icon: const Icon(Icons.casino),
                                  label: Text(
                                    S.current.randomizeWaveLabelEditorPage,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppThemeSpacing.space8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _draftState.clearSelectedWave,
                                  icon: const Icon(Icons.restore),
                                  label: Text(
                                    S.current.resetToAutoLabelEditorPage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(
                          color: AppThemeColors.borderSubtle,
                          height: 32,
                        ),
                        MapEditorSectionLabelWidget(
                          S.current.environmentLabelEditorPage,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            S.current.dynamicWeatherLabelEditorPage,
                            style: const TextStyle(color: AppThemeColors.textMuted),
                          ),
                          value: currentDraft.environment.dynamicWeather,
                          onChanged: (value) =>
                              _draftState.setDynamicWeather(value),
                        ),
                        Text(
                          S.current.sunAngleLabelEditorPage(
                            (currentDraft.environment.sunAngle * 100).round(),
                          ),
                          style: const TextStyle(color: AppThemeColors.textMuted),
                        ),
                        Slider(
                          value: currentDraft.environment.sunAngle,
                          onChanged: (value) => _draftState.setSunAngle(value),
                        ),
                        SizedBox(height: AppThemeSpacing.space8),
                        Text(
                          S.current.previewWeatherLabelEditorPage(
                            (currentPreviewProgress * 100).round(),
                          ),
                          style: const TextStyle(color: AppThemeColors.textMuted),
                        ),
                        Slider(
                          value: currentPreviewProgress,
                          onChanged: (value) =>
                              _draftState.setPreviewProgress(value),
                        ),
                        SizedBox(height: AppThemeSpacing.space8),
                        Text(
                          S.current.weatherTimelineLabelEditorPage,
                          style: const TextStyle(
                            color: AppThemeColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        for (final (index, keyframe)
                            in currentDraft.environment.timeline.indexed)
                          MapEditorWeatherKeyframeEditorWidget(
                            keyframe: keyframe,
                            onChanged: (updated) =>
                                _draftState.replaceKeyframe(index, updated),
                            onRemove: () => _draftState.removeKeyframe(index),
                          ),
                        SizedBox(height: AppThemeSpacing.space8),
                        OutlinedButton.icon(
                          onPressed: _draftState.addKeyframe,
                          icon: const Icon(Icons.add),
                          label: Text(S.current.addKeyframeLabelEditorPage),
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
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _startingGoldController.dispose();
    _waveCountController.dispose();
    _viewerController.dispose();
    _draftState.notice.removeListener(_onDraftNotice);
    _persistenceState.notice.removeListener(_onPersistenceNotice);
    _persistenceState.dispose();
    _draftState.dispose();
    getIt.unregister<MapEditorPersistenceState>();
    getIt.unregister<MapEditorDraftState>();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getIt.registerSingleton<MapEditorDraftState>(
      MapEditorDraftState(widget.initialDraft),
    );
    getIt.registerSingleton<MapEditorPersistenceState>(
      MapEditorPersistenceState(
        getIt<MapEditorDraftState>(),
        getIt<MapDraftRepository>(),
      ),
    );
    _draftState = getIt<MapEditorDraftState>();
    _persistenceState = getIt<MapEditorPersistenceState>();
    _draftState.notice.addListener(_onDraftNotice);
    _persistenceState.notice.addListener(_onPersistenceNotice);
    final draft = widget.initialDraft;
    _nameController.text = draft.name;
    _widthController.text = draft.arenaWidth.toStringAsFixed(0);
    _heightController.text = draft.arenaHeight.toStringAsFixed(0);
    _startingGoldController.text = draft.startingGold.toString();
    _waveCountController.text = draft.waveCount.toString();
    _draftState.initialize();
  }

  void _applyArenaSize() =>
      _draftState.applyArenaSize(_widthController.text, _heightController.text);

  void _applyStartingGold() =>
      _draftState.applyStartingGold(_startingGoldController.text);

  void _applyWaveCount() {
    _draftState.applyWaveCount(_waveCountController.text);
  }

  /// Exports the current draft as a standalone `.json` file the player can
  /// back up, share, or hand-edit - opens the platform's native save/
  /// download dialog (a browser download on web, a save-as dialog on
  /// desktop).
  Future<void> _downloadDraft() => _persistenceState.download();

  /// Surfaces a one-shot notice from [_draftState] as a toast, then clears
  /// it - the state decided WHAT to say, this only performs the
  /// BuildContext-bound display.
  void _onDraftNotice() {
    final value = _draftState.notice.value;
    if (value == null) return;
    _draftState.clearNotice();
    _showToast(value.message, icon: value.icon);
  }

  /// Surfaces a one-shot notice from [_persistenceState] as a toast, then
  /// clears it - see [_onDraftNotice].
  void _onPersistenceNotice() {
    final value = _persistenceState.notice.value;
    if (value == null) return;
    _persistenceState.clearNotice();
    _showToast(value.message, icon: value.icon);
  }

  /// Rasterizes the draft's current terrain and launches a real playthrough
  /// of it via the normal [GamePage] - the base lands at the editor's placed
  /// home site if one was set (falls back to the default east-edge base,
  /// single western approach, otherwise).
  Future<void> _play() async {
    final args = await _persistenceState.preparePlay();
    if (!mounted) return;
    await context.push(Routes.game.route, extra: args);
  }

  void _resetZoom() {
    _draftState.resetZoom();
    _viewerController.value = Matrix4.identity();
  }

  Future<void> _save() => _persistenceState.save();

  /// Floats a brief glass-styled confirmation over the editor - matches the
  /// game's [showGlassMessage] look but is non-modal and auto-dismisses.
  void _showToast(String message, {IconData icon = Icons.check_circle}) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => MapEditorToastWidget(
        message: message,
        icon: icon,
        onDismissed: entry.remove,
      ),
    );
    overlay.insert(entry);
  }

  /// Imports a previously-downloaded `.json` map file, replacing the
  /// editor's current draft contents in place (the draft keeps its id, so
  /// Save continues to overwrite the same slot it was opened from).
  Future<void> _uploadDraft() async {
    final imported = await _persistenceState.upload();
    if (imported == null) return;
    _nameController.text = imported.name;
    _widthController.text = imported.arenaWidth.toStringAsFixed(0);
    _heightController.text = imported.arenaHeight.toStringAsFixed(0);
    _startingGoldController.text = imported.startingGold.toString();
    _waveCountController.text = imported.waveCount.toString();
  }

  void _zoomBy(double factor) {
    final next = _draftState.zoomBy(factor);
    _viewerController.value = Matrix4.identity()
      ..scaleByDouble(next, next, next, 1);
  }
}
