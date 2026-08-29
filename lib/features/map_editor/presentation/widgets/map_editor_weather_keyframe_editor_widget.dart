import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_borders.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';
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
              children: [
                Expanded(
                  child: Text(
                    S.current.keyframeAtProgressLabelEditorPage(
                      (keyframe.atProgress * 100).round(),
                    ),
                    style: const TextStyle(
                      color: AppThemeColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
}
