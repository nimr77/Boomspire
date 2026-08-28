import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../theme/app_theme/app_theme_borders.dart';
import '../../../theme/app_theme/app_theme_colors.dart';
import '../../../theme/app_theme/app_theme_paddings.dart';
import '../../terrain/extensions/biome_extensions.dart';
import '../domain/models/map_draft.dart';
import '../domain/repos/map_draft_repository.dart';
import 'map_editor_page.dart';
import 'state/map_drafts_list_state.dart';

/// Entry point for the map editor: browse, open, create, or delete
/// user-authored [MapDraft]s stored via [MapDraftRepository].
class MapDraftsListPage extends StatefulWidget {
  const MapDraftsListPage({super.key});

  @override
  State<MapDraftsListPage> createState() => _MapDraftsListPageState();
}

class _MapDraftsListPageState extends State<MapDraftsListPage> {
  final MapDraftsListState _state = MapDraftsListState(
    getIt<MapDraftRepository>(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.gradientPanelEnd,
        title: const Text('Map Editor'),
      ),
      floatingActionButton: OpenContainer<void>(
        transitionType: ContainerTransitionType.fade,
        closedElevation: 6,
        closedShape: const StadiumBorder(),
        closedColor: AppThemeColors.surfacePanel,
        openColor: AppThemeColors.background,
        onClosed: (_) => _refresh(),
        closedBuilder: (context, openContainer) =>
            FloatingActionButton.extended(
              onPressed: openContainer,
              icon: const Icon(Icons.add),
              label: const Text('New Map'),
            ),
        openBuilder: (context, closeContainer) =>
            MapEditorPage(initialDraft: _state.pendingNewDraft.value),
      ),
      body: ValueListenableBuilder<List<MapDraft>?>(
        valueListenable: _state.drafts,
        builder: (context, drafts, _) {
          if (drafts == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (drafts.isEmpty) {
            return const Center(
              child: Text(
                'No saved maps yet - tap "New Map" to start.',
                style: TextStyle(color: AppThemeColors.textSecondary),
              ),
            );
          }
          return ListView.builder(
            padding: AppThemePaddings.ltrb16_16_16_96,
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              final draft = drafts[index];
              return Padding(
                padding: AppThemePaddings.bottom12,
                child: OpenContainer<void>(
                  transitionType: ContainerTransitionType.fade,
                  closedElevation: 2,
                  closedShape: RoundedRectangleBorder(
                    borderRadius: AppThemeBorders.radius14,
                  ),
                  closedColor: AppThemeColors.surfaceCard,
                  openColor: AppThemeColors.background,
                  onClosed: (_) => _refresh(),
                  closedBuilder: (context, openContainer) => ListTile(
                    onTap: openContainer,
                    title: Text(
                      draft.name,
                      style: const TextStyle(color: AppThemeColors.textPrimary),
                    ),
                    subtitle: Text(
                      '${draft.biome.displayName} · ${draft.mode.name} · '
                      '${draft.arenaWidth.toInt()}x${draft.arenaHeight.toInt()}',
                      style: const TextStyle(
                        color: AppThemeColors.textSecondary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppThemeColors.accentRed,
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

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _state.refresh();
  }

  Future<void> _deleteDraft(String id) async {
    await _state.deleteDraft(id);
  }

  void _refresh() {
    _state.refresh();
  }
}
