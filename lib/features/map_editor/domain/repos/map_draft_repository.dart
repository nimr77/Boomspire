import '../models/map_draft.dart';

/// Persists user-authored map drafts made in the in-app map editor.
///
/// Backed by on-device storage on every platform this app ships to today
/// (desktop file-backed, web browser-storage-backed - see
/// `LocalMapDraftRepositoryImpl`); a future cloud-synced implementation can
/// satisfy this same interface without touching editor UI code.
abstract class MapDraftRepository {
  Future<List<MapDraft>> listDrafts();

  Future<MapDraft?> loadDraft(String id);

  Future<void> saveDraft(MapDraft draft);

  Future<void> deleteDraft(String id);
}
