import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../game_core/domain/models/game_scene.dart';
import '../../../terrain/domain/models/biome.dart';
import '../biome_preview.dart';

/// A featured skirmish scene tile in [SkirmishLevelSelectPage] - live
/// terrain preview plus name/briefing, tap to open placement.
class SkirmishLevelSelectSceneCardWidget extends StatelessWidget {
  final GameScene scene;

  const SkirmishLevelSelectSceneCardWidget({super.key, required this.scene});

  @override
  Widget build(BuildContext context) {
    final palette = scene.biome.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(
          Routes.skirmishPlacement.route,
          extra: SkirmishPlacementArgs(scene: scene),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              BiomePreview(scene: scene),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                  border: Border.all(
                    color: palette.ridgeLight.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        scene.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scene.briefing,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
