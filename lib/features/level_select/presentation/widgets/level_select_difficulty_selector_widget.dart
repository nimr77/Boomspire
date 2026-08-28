import 'package:flutter/material.dart';

import '../../../game_core/domain/models/game_difficulty.dart';
import 'level_select_difficulty_segment_widget.dart';

/// Segmented easy/normal/hard picker - scales AI aggression and rations the
/// Laser Lance build limit for the run about to start. Styled as a single
/// HUD panel (matching the build menu's tab strip) rather than loose chips.
class LevelSelectDifficultySelectorWidget extends StatelessWidget {
  final GameDifficulty value;
  final ValueChanged<GameDifficulty> onChanged;

  const LevelSelectDifficultySelectorWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A323C), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final difficulty in GameDifficulty.values)
            LevelSelectDifficultySegmentWidget(
              label: difficulty.label,
              selected: value == difficulty,
              onTap: () => onChanged(difficulty),
            ),
        ],
      ),
    );
  }
}
