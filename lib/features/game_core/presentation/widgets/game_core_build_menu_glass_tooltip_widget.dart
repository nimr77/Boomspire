import 'dart:ui';

import 'package:flutter/material.dart';

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
        Icon(icon, size: 12, color: Colors.white70),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
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
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
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
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 12,
                        color: Colors.amberAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lockReason!,
                        style: const TextStyle(
                          color: Colors.amberAccent,
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
