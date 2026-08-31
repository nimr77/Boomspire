import 'dart:math';

import '../../../../domain/enums/wind_type.dart';
import 'autumn_leaf_colors.dart';

/// Spawns a biome/style-appropriate batch of wind particles for [style]
/// (count and per-field ranges vary by style) from a single shared
/// [Random] sequence, scattered across an arena of size [arenaWidth] x
/// [arenaHeight].
List<WindParticleSpawn> spawnWindParticles({
  required WindType style,
  required double arenaWidth,
  required double arenaHeight,
}) {
  final rnd = Random(13);
  final count = switch (style) {
    WindType.snow => 50,
    WindType.autumnLeaves || WindType.ash => 26,
    WindType.grassLeaves || WindType.sand || WindType.dust => 30,
    WindType.automatic => 0, // unreachable - always resolved concretely
  };
  return [
    for (var i = 0; i < count; i++)
      (
        x: rnd.nextDouble() * arenaWidth,
        y: rnd.nextDouble() * arenaHeight,
        speed: switch (style) {
          WindType.grassLeaves => 45 + rnd.nextDouble() * 35,
          WindType.snow => 22 + rnd.nextDouble() * 26,
          WindType.sand => 90 + rnd.nextDouble() * 70,
          WindType.dust => 55 + rnd.nextDouble() * 40,
          WindType.autumnLeaves => 18 + rnd.nextDouble() * 22,
          WindType.ash => 16 + rnd.nextDouble() * 20,
          WindType.automatic => 0,
        },
        drop: switch (style) {
          WindType.snow => 16 + rnd.nextDouble() * 18,
          WindType.autumnLeaves => 12 + rnd.nextDouble() * 14,
          WindType.ash => 10 + rnd.nextDouble() * 12,
          WindType.grassLeaves || WindType.sand || WindType.dust => 0,
          WindType.automatic => 0,
        },
        scale: 0.5 + rnd.nextDouble() * 1.0,
        opacity: 0.12 + rnd.nextDouble() * 0.3,
        bobPhase: rnd.nextDouble() * 2 * pi,
        gustPhase: rnd.nextDouble() * 2 * pi,
        rotation: rnd.nextDouble() * 2 * pi,
        rotationSpeed: (rnd.nextDouble() - 0.5) * 2.4,
        colorIndex: rnd.nextInt(kAutumnLeafColors.length),
      ),
  ];
}

/// One spawned wind particle's initial randomized parameters.
typedef WindParticleSpawn = ({
  double x,
  double y,
  double speed,
  double drop,
  double scale,
  double opacity,
  double bobPhase,
  double gustPhase,
  double rotation,
  double rotationSpeed,
  int colorIndex,
});
