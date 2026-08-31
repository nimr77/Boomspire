import 'dart:math';

/// Spawns [cloudCount] clouds followed by [fogCount] fog banks from a
/// single shared random sequence (clouds first, then fog banks - matching
/// draw order matters for determinism), scattered across an arena of size
/// [arenaWidth] x [arenaHeight].
({List<CloudSpawn> clouds, List<FogBankSpawn> fogBanks})
spawnCloudLayerEntities({
  required double arenaWidth,
  required double arenaHeight,
  required int cloudCount,
  required int fogCount,
}) {
  final rnd = Random(7);
  final clouds = <CloudSpawn>[
    for (var i = 0; i < cloudCount; i++)
      (
        x: rnd.nextDouble() * arenaWidth,
        y: rnd.nextDouble() * arenaHeight * 0.6,
        speed: 6 + rnd.nextDouble() * 14,
        scale: 0.6 + rnd.nextDouble() * 1.1,
        baseOpacity: 0.16 + rnd.nextDouble() * 0.2,
        seed: rnd.nextInt(1 << 30),
        bobPhase: rnd.nextDouble() * 2 * pi,
        // Farther/smaller clouds drift slower and breathe more gently -
        // a cheap parallax depth cue without a real z-axis.
        depth: 0.4 + rnd.nextDouble() * 0.6,
      ),
  ];
  final fogBanks = <FogBankSpawn>[
    for (var i = 0; i < fogCount; i++)
      (
        x: rnd.nextDouble() * arenaWidth,
        y: arenaHeight * (0.55 + rnd.nextDouble() * 0.45),
        speed: 3 + rnd.nextDouble() * 7,
        scale: 1.1 + rnd.nextDouble() * 1.6,
        baseOpacity: 0.05 + rnd.nextDouble() * 0.07,
        seed: rnd.nextInt(1 << 30),
        bobPhase: rnd.nextDouble() * 2 * pi,
      ),
  ];
  return (clouds: clouds, fogBanks: fogBanks);
}

/// One spawned cloud puff-cluster's initial randomized parameters.
typedef CloudSpawn = ({
  double x,
  double y,
  double speed,
  double scale,
  double baseOpacity,
  int seed,
  double bobPhase,
  double depth,
});

/// One spawned ground-fog bank's initial randomized parameters.
typedef FogBankSpawn = ({
  double x,
  double y,
  double speed,
  double scale,
  double baseOpacity,
  int seed,
  double bobPhase,
});
