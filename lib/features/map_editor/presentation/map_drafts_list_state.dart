import 'package:flutter/foundation.dart';

import '../domain/models/map_draft.dart';
import '../domain/repos/map_draft_repository.dart';

/// Page-owned state for [MapDraftsListPage]: loads saved drafts and
/// exposes them read-only, with [refresh]/[deleteDraft] to mutate storage
/// and reload. Instantiated and disposed by the page's own State.
class MapDraftsListState {
  final MapDraftRepository _draftRepository;
  final ValueNotifier<List<MapDraft>?> _drafts = ValueNotifier(null);
  final ValueNotifier<MapDraft> _pendingNewDraft = ValueNotifier(
    _freshDraft(),
  );

  MapDraftsListState(this._draftRepository);

  ValueListenable<List<MapDraft>?> get drafts => _drafts;
  ValueListenable<MapDraft> get pendingNewDraft => _pendingNewDraft;

  Future<void> deleteDraft(String id) async {
    await _draftRepository.deleteDraft(id);
    await refresh();
  }

  void dispose() {
    _drafts.dispose();
    _pendingNewDraft.dispose();
  }

  Future<void> refresh() async {
    _drafts.value = await _draftRepository.listDrafts();
    _pendingNewDraft.value = _freshDraft();
  }

  static MapDraft _freshDraft() => MapDraft(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    name: 'New Map',
  );
}
