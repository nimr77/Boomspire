import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/map_draft.dart';
import '../domain/repos/map_draft_repository.dart';

/// On-device draft storage via `shared_preferences` - browser-storage-backed
/// on web, file-backed on desktop, so the same code path works as a hybrid
/// local store on every platform without any platform-specific branching.
///
/// All drafts are kept as one JSON array under a single key (list of maps
/// is expected to stay small - user-authored, not a big content catalog).
class LocalMapDraftRepositoryImpl implements MapDraftRepository {
  static const _key = 'boomspire.map_editor.drafts.v1';

  @override
  Future<void> deleteDraft(String id) async {
    final drafts = await listDrafts();
    drafts.removeWhere((d) => d.id == id);
    await _persist(drafts);
  }

  @override
  Future<List<MapDraft>> listDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MapDraft.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupt/foreign data shouldn't crash the editor's draft list.
      return [];
    }
  }

  @override
  Future<MapDraft?> loadDraft(String id) async {
    final drafts = await listDrafts();
    for (final draft in drafts) {
      if (draft.id == id) return draft;
    }
    return null;
  }

  @override
  Future<void> saveDraft(MapDraft draft) async {
    final drafts = await listDrafts();
    final index = drafts.indexWhere((d) => d.id == draft.id);
    if (index >= 0) {
      drafts[index] = draft;
    } else {
      drafts.add(draft);
    }
    await _persist(drafts);
  }

  Future<void> _persist(List<MapDraft> drafts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(drafts.map((d) => d.toJson()).toList()),
    );
  }
}
