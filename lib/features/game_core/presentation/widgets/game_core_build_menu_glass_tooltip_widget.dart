import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../theme/app_theme/app_theme_borders.dart';
import '../../../../theme/app_theme/app_theme_colors.dart';
import '../../../../theme/app_theme/app_theme_paddings.dart';
import '../../../../theme/app_theme/app_theme_spacing.dart';
import '../../../towers/domain/models/unit_blueprint.dart';

/// Frosted-glass hover card: build cost, core stats, and (when relevant)
/// the build-limit count and unlock requirement for a tower type.
class GameCoreBuildMenuGlassTooltipWidget extends StatelessWidget {
  final UnitBlueprint blueprint;
  final String? lockReason;
  final int builtCount;
  final int? limit;

  const GameCoreBuildMenuGlassTooltipWidget({
    super.key,
    required this.blueprint,
    required this.lockReason,
    required this.builtCount,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    Widget stat(IconData icon, String value) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppThemeColors.textMuted),
        SizedBox(width: AppThemeSpacing.space3),
        Text(
          value,
          style: const TextStyle(
            color: AppThemeColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Material(
      color: AppThemeColors.transparent,
      child: ClipRRect(
        borderRadius: AppThemeBorders.radius12,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: AppThemePaddings.h12v10,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: AppThemeBorders.radius12,
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blueprint.name,
                  style: const TextStyle(
                    color: AppThemeColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppThemeSpacing.space6),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    stat(Icons.paid, '${blueprint.cost}g'),
                    if (blueprint.damage > 0)
                      stat(Icons.flash_on, blueprint.damage.toStringAsFixed(0)),
                    if (blueprint.range > 0)
                      stat(
                        Icons.social_distance,
                        blueprint.range.toStringAsFixed(0),
                      ),
                    if (blueprint.minRange > 0)
                      stat(Icons.block, blueprint.minRange.toStringAsFixed(0)),
                    if (blueprint.damage > 0)
                      stat(
                        Icons.timer,
                        '${blueprint.fireRate.toStringAsFixed(1)}s',
                      ),
                    if (blueprint.splashRadius > 0)
                      stat(
                        Icons.blur_circular,
                        blueprint.splashRadius.toStringAsFixed(0),
                      ),
                  ],
                ),
                if (limit != null) ...[
                  SizedBox(height: AppThemeSpacing.space6),
                  Text(
                    '$builtCount / $limit built',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (lockReason != null) ...[
                  SizedBox(height: AppThemeSpacing.space6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 12,
                        color: AppThemeColors.accentAmber,
                      ),
                      SizedBox(width: AppThemeSpacing.space4),
                      Text(
                        lockReason!,
                        style: const TextStyle(
                          color: AppThemeColors.accentAmber,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
