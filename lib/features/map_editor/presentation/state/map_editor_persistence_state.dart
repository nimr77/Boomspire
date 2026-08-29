import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons;

import '../../../../core/router/routes.dart';
import '../../../../generated/l10n.dart';
import '../../../game_core/domain/models/game_scene.dart';
import '../../../waves/impl/wave_repository_impl.dart';
import '../../domain/models/editor_terrain_preview.dart';
import '../../domain/models/map_draft.dart';
import '../../domain/repos/map_draft_repository.dart';
import '../../impl/draft_wave_repository.dart';
import '../../impl/editor_terrain_generator.dart';
import '../../impl/map_draft_terrain_repository.dart';
import 'map_editor_draft_state.dart';
import 'map_editor_notice.dart';

/// Owns the map editor's save/load/export flow: persisting a draft,
/// downloading/uploading it as a `.json` file, and preparing a real
/// playthrough of it - depends on [MapEditorDraftState] (this feature's
/// other flow) to read/replace the draft being worked on.
///
/// Registered per-editor-session with `getIt` by [MapEditorPage] (see the
/// `presentation-state-layer` instructions) and disposed when the page is
/// disposed.
class MapEditorPersistenceState {
  final MapEditorDraftState _draftState;
  final MapDraftRepository _draftRepository;
  final EditorTerrainGenerator _generator;

  final ValueNotifier<bool> _saving = ValueNotifier(false);
  final ValueNotifier<bool> _playing = ValueNotifier(false);
  final ValueNotifier<bool> _downloading = ValueNotifier(false);
  final ValueNotifier<bool> _uploading = ValueNotifier(false);
  final ValueNotifier<MapEditorNotice?> _notice = ValueNotifier(null);

  MapEditorPersistenceState(
    this._draftState,
    this._draftRepository, {
    EditorTerrainGenerator? generator,
  }) : _generator = generator ?? EditorTerrainGenerator();

  ValueListenable<bool> get downloading => _downloading;
  ValueListenable<MapEditorNotice?> get notice => _notice;
  ValueListenable<bool> get playing => _playing;
  ValueListenable<bool> get saving => _saving;
  ValueListenable<bool> get uploading => _uploading;

  void clearNotice() => _notice.value = null;

  void dispose() {
    _saving.dispose();
    _playing.dispose();
    _downloading.dispose();
    _uploading.dispose();
    _notice.dispose();
  }

  /// Exports the current draft as a standalone `.json` file the player can
  /// back up, share, or hand-edit - opens the platform's native save/
  /// download dialog (a browser download on web, a save-as dialog on
  /// desktop).
  Future<void> download() async {
    _downloading.value = true;
    try {
      final draft = _draftState.draft.value;
      final bytes = _encodeDraft(draft);
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Download map',
        fileName: '${_safeFileName(draft.name)}.json',
        bytes: bytes,
        mimeType: 'application/json',
      );
      if (saved != null) {
        _notice.value = MapEditorNotice(
          S.current.downloadedMapEditorPage(draft.name),
        );
      }
    } finally {
      _downloading.value = false;
    }
  }

  /// Rasterizes the current draft and returns everything [GamePage] needs
  /// to test-play it - the base lands at the editor's placed home site if
  /// one was set (falls back to the default east-edge base otherwise).
  Future<GameRouteArgs> preparePlay() async {
    _playing.value = true;
    try {
      final draft = _draftState.draft.value;
      final preview = await _generator.generate(draft);
      if (draft.mode == GameMode.skirmish) {
        _notice.value = MapEditorNotice(
          S.current.skirmishPlaytestComingSoonEditorPage,
          icon: Icons.info_outline,
        );
      }
      return _buildLaunchArgs(draft, preview);
    } finally {
      _playing.value = false;
    }
  }

  Future<void> save() async {
    _saving.value = true;
    try {
      final draft = _draftState.draft.value;
      await _draftRepository.saveDraft(draft);
      _notice.value = MapEditorNotice(S.current.savedMapEditorPage(draft.name));
    } finally {
      _saving.value = false;
    }
  }

  /// Imports a previously-downloaded `.json` map file, replacing the
  /// editor's current draft contents in place (the draft keeps its id, so
  /// Save continues to overwrite the same slot it was opened from). Returns
  /// the imported draft (so the page can resync its text fields) or `null`
  /// if the user cancelled or the file couldn't be read.
  Future<MapDraft?> upload() async {
    _uploading.value = true;
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: 'Upload map',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (file == null) return null;
      final imported = await _decodeDraftFile(file, _draftState.draft.value.id);
      await _draftState.replaceDraft(imported);
      _notice.value = MapEditorNotice(
        S.current.importedMapEditorPage(imported.name),
      );
      return imported;
    } catch (_) {
      _notice.value = MapEditorNotice(
        S.current.couldNotReadMapEditorPage,
        icon: Icons.error_outline,
      );
      return null;
    } finally {
      _uploading.value = false;
    }
  }

  GameRouteArgs _buildLaunchArgs(MapDraft draft, EditorTerrainPreview preview) {
    return GameRouteArgs(
      scene: GameScene(
        id: 'draft-${draft.id}',
        name: draft.name.isEmpty ? S.current.untitledMapEditorPage : draft.name,
        briefing: S.current.testingHandDrawnMapBriefingEditorPage,
        biome: draft.biome,
        waveCount: draft.waveCount,
        startingGold: draft.startingGold,
        environment: draft.environment,
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
    );
  }

  Future<MapDraft> _decodeDraftFile(dynamic file, String keepId) async {
    final bytes = await file.readAsBytes();
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return MapDraft.fromJson(json).copyWith(id: keepId);
  }

  Uint8List _encodeDraft(MapDraft draft) => Uint8List.fromList(
    utf8.encode(const JsonEncoder.withIndent('  ').convert(draft.toJson())),
  );

  String _safeFileName(String name) =>
      name.trim().isEmpty ? 'map' : name.trim();
}
