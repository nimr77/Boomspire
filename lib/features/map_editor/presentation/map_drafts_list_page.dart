import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../terrain/domain/models/biome.dart';
import '../domain/models/map_draft.dart';
import '../domain/repos/map_draft_repository.dart';
import 'map_editor_page.dart';

/// Entry point for the map editor: browse, open, create, or delete
/// user-authored [MapDraft]s stored via [MapDraftRepository].
class MapDraftsListPage extends StatefulWidget {
  const MapDraftsListPage({super.key});

  @override
  State<MapDraftsListPage> createState() => _MapDraftsListPageState();
}

class _MapDraftsListPageState extends State<MapDraftsListPage> {
  final MapDraftRepository _draftRepository = getIt<MapDraftRepository>();
  late Future<List<MapDraft>> _draftsFuture = _draftRepository.listDrafts();
  late MapDraft _pendingNewDraft = _freshDraft();

  MapDraft _freshDraft() => MapDraft(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    name: 'New Map',
  );

  void _refresh() => setState(() {
    _draftsFuture = _draftRepository.listDrafts();
    _pendingNewDraft = _freshDraft();
  });

  Future<void> _deleteDraft(String id) async {
    await _draftRepository.deleteDraft(id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11161D),
        title: const Text('Map Editor'),
      ),
      floatingActionButton: OpenContainer<void>(
        transitionType: ContainerTransitionType.fade,
        closedElevation: 6,
        closedShape: const StadiumBorder(),
        closedColor: const Color(0xFF1A1F26),
        openColor: const Color(0xFF0A0E14),
        onClosed: (_) => _refresh(),
        closedBuilder: (context, openContainer) => FloatingActionButton.extended(
          onPressed: openContainer,
          icon: const Icon(Icons.add),
          label: const Text('New Map'),
        ),
        openBuilder: (context, closeContainer) =>
            MapEditorPage(initialDraft: _pendingNewDraft),
      ),
      body: FutureBuilder<List<MapDraft>>(
        future: _draftsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final drafts = snapshot.data!;
          if (drafts.isEmpty) {
            return const Center(
              child: Text(
                'No saved maps yet - tap "New Map" to start.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              final draft = drafts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OpenContainer<void>(
                  transitionType: ContainerTransitionType.fade,
                  closedElevation: 2,
                  closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  closedColor: const Color(0xFF161B22),
                  openColor: const Color(0xFF0A0E14),
                  onClosed: (_) => _refresh(),
                  closedBuilder: (context, openContainer) => ListTile(
                    onTap: openContainer,
                    title: Text(
                      draft.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${draft.biome.displayName} · ${draft.mode.name} · '
                      '${draft.arenaWidth.toInt()}x${draft.arenaHeight.toInt()}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _deleteDraft(draft.id),
                    ),
                  ),
                  openBuilder: (context, closeContainer) =>
                      MapEditorPage(initialDraft: draft),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

