import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
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
    return Card(
      color: AppThemeColors.surfacePanel,
      margin: AppThemePaddings.v6,
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
                    style: const TextStyle(color: AppThemeColors.textPrimary),
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
              S.current.windLabelEditorPage,
              keyframe.windStrength,
              (v) => onChanged(keyframe.copyWith(windStrength: v)),
            ),
            _keyframeSlider(
              S.current.rainLabelEditorPage,
              keyframe.rainIntensity,
              (v) => onChanged(keyframe.copyWith(rainIntensity: v)),
            ),
            _keyframeSlider(
              S.current.snowLabelEditorPage,
              keyframe.snowIntensity,
              (v) => onChanged(keyframe.copyWith(snowIntensity: v)),
            ),
            _keyframeSlider(
              S.current.fogLabelEditorPage,
              keyframe.fogDensity,
              (v) => onChanged(keyframe.copyWith(fogDensity: v)),
            ),
            _keyframeSlider(
              S.current.cloudLabelEditorPage,
              keyframe.cloudCover,
              (v) => onChanged(keyframe.copyWith(cloudCover: v)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keyframeSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: const TextStyle(
              color: AppThemeColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}
