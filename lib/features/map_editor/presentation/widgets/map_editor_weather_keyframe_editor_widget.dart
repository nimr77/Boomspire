import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';
import '../../../terrain/extensions/wind_type_extensions.dart';
import '../../domain/models/weather_keyframe.dart';

/// One editable card in the environment section's weather timeline - lets
/// an author tweak a single [WeatherKeyframe]'s intensities or remove it.
class MapEditorWeatherKeyframeEditorWidget extends StatelessWidget {
  final WeatherKeyframe keyframe;
  final ValueChanged<WeatherKeyframe> onChanged;
  final VoidCallback onRemove;

  const MapEditorWeatherKeyframeEditorWidget({
    super.key,
    required this.keyframe,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppThemePaddings.v6,
      decoration: BoxDecoration(
        color: AppThemeColors.surfacePanel,
        borderRadius: AppThemeBorders.radius12,
        border: Border.all(
          color: AppThemeColors.borderSubtle,
          width: AppThemeBorders.width1,
        ),
      ),
      child: Padding(
        padding: AppThemePaddings.all12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppThemeColors.textSecondary,
                    size: 18,
                  ),
                  onPressed: onRemove,
                ),
              ],
            ),
            _keyframeSlider(
              icon: Icons.air,
              color: AppThemeColors.accentLightBlue,
              label: S.current.windLabelEditorPage,
              value: keyframe.windStrength,
              onChanged: (v) => onChanged(keyframe.copyWith(windStrength: v)),
            ),
            _keyframeWindTypeRow(),
            _keyframeSlider(
              icon: Icons.water_drop,
              color: AppThemeColors.accentCyan,
              label: S.current.rainLabelEditorPage,
              value: keyframe.rainIntensity,
              onChanged: (v) => onChanged(keyframe.copyWith(rainIntensity: v)),
            ),
            _keyframeSlider(
              icon: Icons.ac_unit,
              color: Colors.white70,
              label: S.current.snowLabelEditorPage,
              value: keyframe.snowIntensity,
              onChanged: (v) => onChanged(keyframe.copyWith(snowIntensity: v)),
            ),
            _keyframeSlider(
              icon: Icons.blur_on,
              color: AppThemeColors.textMuted,
              label: S.current.fogLabelEditorPage,
              value: keyframe.fogDensity,
              onChanged: (v) => onChanged(keyframe.copyWith(fogDensity: v)),
            ),
            _keyframeSlider(
              icon: Icons.cloud,
              color: AppThemeColors.accentLightGreen,
              label: S.current.cloudLabelEditorPage,
              value: keyframe.cloudCover,
              onChanged: (v) => onChanged(keyframe.copyWith(cloudCover: v)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keyframeSlider({
    required IconData icon,
    required Color color,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: AppThemeSpacing.space6),
        SizedBox(
          width: 38,
          child: Text(
            label,
            style: const TextStyle(
              color: AppThemeColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            activeColor: color,
            inactiveColor: color.withValues(alpha: 0.25),
            thumbColor: color,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: AppThemeSpacing.space8),
        SizedBox(
          width: 32,
          child: Text(
            S.current.zoomPercentEditorPage((value * 100).round()),
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppThemeColors.textMuted,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  /// Same leading-icon/label layout as [_keyframeSlider], but for the
  /// per-keyframe [WindType] picker instead of a slider - keeps the whole
  /// card visually consistent instead of the dropdown looking bolted on.
  /// The icon/color reflect the currently-selected type (and each dropdown
  /// entry repeats its own icon/color) so the control reads at a glance
  /// instead of needing the text label alone.
  Widget _keyframeWindTypeRow() {
    return Padding(
      padding: EdgeInsets.only(left: 22, bottom: AppThemeSpacing.space6),
      child: Row(
        children: [
          Icon(
            _windTypeIcon(keyframe.windType),
            color: _windTypeColor(keyframe.windType),
            size: 16,
          ),
          SizedBox(width: AppThemeSpacing.space6),
          SizedBox(
            width: 38,
            child: Text(
              S.current.windTypeFieldLabelEditorPage,
              style: const TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 2,
            ),
          ),
          Expanded(
            child: DropdownButtonFormField<WindType>(
              initialValue: keyframe.windType,
              isDense: true,
              isExpanded: true,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppThemeColors.textMuted,
                size: 18,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              dropdownColor: AppThemeColors.surfacePanel,
              style: const TextStyle(
                color: AppThemeColors.textPrimary,
                fontSize: 13,
              ),
              items: [
                for (final type in WindType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _windTypeIcon(type),
                          color: _windTypeColor(type),
                          size: 14,
                        ),
                        SizedBox(width: AppThemeSpacing.space6),
                        Text(type.label),
                      ],
                    ),
                  ),
              ],
              onChanged: (type) {
                if (type != null) {
                  onChanged(keyframe.copyWith(windType: type));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Mirrors the particle colors `TerrainComponent`/`WindEffectComponent`
  /// actually render for each [WindType], so the picker's icon color is a
  /// true preview of what that choice looks like in-game. [WindType.automatic]
  /// gets a neutral tone instead of white since it has no single fixed
  /// color of its own (it inherits whatever the map's biome resolves to).
  Color _windTypeColor(WindType type) => switch (type) {
    WindType.automatic => AppThemeColors.textSecondary,
    WindType.grassLeaves => const Color(0xFFB7C97A),
    WindType.autumnLeaves => const Color(0xFFC1502D),
    WindType.sand => const Color(0xFFD8C08A),
    WindType.snow => Colors.white70,
    WindType.dust => Colors.white,
    WindType.ash => const Color(0xFF9E9E9E),
  };

  IconData _windTypeIcon(WindType type) => switch (type) {
    WindType.automatic => Icons.auto_awesome,
    WindType.grassLeaves => Icons.grass,
    WindType.autumnLeaves => Icons.eco,
    WindType.sand => Icons.terrain,
    WindType.dust => Icons.blur_on,
    WindType.snow => Icons.ac_unit,
    WindType.ash => Icons.local_fire_department,
  };
}
