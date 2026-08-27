import 'package:flutter/foundation.dart';

import '../../game_core/domain/models/game_scene.dart';
import '../../map_editor/domain/models/map_draft.dart';
import '../../map_editor/domain/repos/map_draft_repository.dart';

/// Page-owned state for [SkirmishLevelSelectPage]: loads the user's
/// skirmish-mode map drafts once and exposes them read-only. Instantiated
/// and disposed by the page's own State.
class SkirmishLevelSelectState {
  final MapDraftRepository _draftRepository;
  final ValueNotifier<List<MapDraft>?> _drafts = ValueNotifier(null);

  SkirmishLevelSelectState(this._draftRepository);

  ValueListenable<List<MapDraft>?> get drafts => _drafts;

  Future<void> load() async {
    final all = await _draftRepository.listDrafts();
    _drafts.value = all.where((d) => d.mode == GameMode.skirmish).toList();
  }

  void dispose() {
    _drafts.dispose();
  }
}
