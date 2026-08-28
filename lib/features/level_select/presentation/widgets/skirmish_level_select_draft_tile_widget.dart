import 'package:flutter/material.dart';

import '../../../../theme/app_theme/app_theme_colors.dart';
import '../../../map_editor/domain/models/map_draft.dart';
import '../../../terrain/extensions/biome_extensions.dart';

/// One user-authored skirmish [MapDraft] row in [SkirmishLevelSelectPage]'s
/// "Custom Maps" list - name, biome, home-site count, tap to place & play.
class SkirmishLevelSelectDraftTileWidget extends StatelessWidget {
  final MapDraft draft;
  final VoidCallback onTap;

  const SkirmishLevelSelectDraftTileWidget({
    super.key,
    required this.draft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppThemeColors.surfaceCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: const Icon(
            Icons.map_outlined,
            color: AppThemeColors.accentRed,
          ),
          title: Text(
            draft.name,
            style: const TextStyle(color: AppThemeColors.textPrimary),
          ),
          subtitle: Text(
            '${draft.biome.displayName} · ${draft.homeSites.length} '
            'home site${draft.homeSites.length == 1 ? '' : 's'}',
            style: const TextStyle(color: AppThemeColors.textSecondary),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppThemeColors.textFaint,
          ),
        ),
      ),
    );
  }
}
