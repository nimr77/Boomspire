import 'package:flutter/foundation.dart';

import '../../../map_editor/domain/models/editor_terrain_preview.dart';
import '../../../map_editor/domain/models/map_draft.dart';
import '../../../map_editor/impl/editor_terrain_generator.dart';

/// Page-owned state for [SkirmishPlacementPage]'s draft preview: generates
/// the [EditorTerrainPreview] for a hand-authored map once and caches the
/// in-flight future so both the UI and the "Start Battle" launch path await
/// the same result. Instantiated and disposed by the page's own State.
class SkirmishPlacementState {
  Future<EditorTerrainPreview>? _future;
  final ValueNotifier<EditorTerrainPreview?> _preview = ValueNotifier(null);
  final ValueNotifier<int?> _selectedSlot = ValueNotifier(null);
  final ValueNotifier<bool> _launching = ValueNotifier(false);

  ValueListenable<bool> get launching => _launching;
  ValueListenable<EditorTerrainPreview?> get preview => _preview;
  ValueListenable<int?> get selectedSlot => _selectedSlot;

  void dispose() {
    _preview.dispose();
    _selectedSlot.dispose();
    _launching.dispose();
  }

  Future<EditorTerrainPreview> load(MapDraft draft) => _future ??= _load(draft);

  void selectSlot(int? index) => _selectedSlot.value = index;

  void setLaunching(bool value) => _launching.value = value;

  Future<EditorTerrainPreview> _load(MapDraft draft) async {
    final result = await EditorTerrainGenerator().generate(draft);
    _preview.value = result;
    return result;
  }
}
