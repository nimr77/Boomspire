import 'package:flutter/foundation.dart';

import '../domain/models/map_draft.dart';
import '../domain/repos/map_draft_repository.dart';

/// Page-owned state for [MapDraftsListPage]: loads saved drafts and
/// exposes them read-only, with [refresh]/[deleteDraft] to mutate storage
/// and reload. Instantiated and disposed by the page's own State.
class MapDraftsListState {
  final MapDraftRepository _draftRepository;
  final ValueNotifier<List<MapDraft>?> _drafts = ValueNotifier(null);

  MapDraftsListState(this._draftRepository);

  ValueListenable<List<MapDraft>?> get drafts => _drafts;

  Future<void> refresh() async {
    _drafts.value = await _draftRepository.listDrafts();
  }

  Future<void> deleteDraft(String id) async {
    await _draftRepository.deleteDraft(id);
    await refresh();
  }

  void dispose() {
    _drafts.dispose();
  }
}
