import 'package:flutter/material.dart' show Color;

import 'obstacle_kind.dart';

/// A selectable map theme. Drives ground color palette, which high-ground
/// obstacle shape is used, whether a river or dry valley cuts the map, and
/// whether decorative trees are scattered.
enum Biome {
  grassPlains,
  snowTundra,
  desertDunes,
  mountainForest,
  cityRuins,
  savanna,
  frozenPeaks,
  sea,
}

class BiomePalette {
  const BiomePalette({
    required this.groundTop,
    required this.groundMid,
    required this.groundBottom,
    required this.ridgeLight,
    required this.ridgeDark,
    required this.capColor,
    required this.highGround,
    required this.crossing,
    required this.hasTrees,
  });

  final Color groundTop;
  final Color groundMid;
  final Color groundBottom;
  final Color ridgeLight;
  final Color ridgeDark;
  final Color capColor;

  /// Primary scattered obstacle (mountain peaks or sand dunes).
  final ObstacleKind highGround;

  /// Winding barrier obstacle that cuts across the map (river or valley).
  final ObstacleKind crossing;
  final bool hasTrees;
}

extension BiomeX on Biome {
  String get displayName => switch (this) {
    Biome.grassPlains => 'Grass Plains',
    Biome.snowTundra => 'Snow Tundra',
    Biome.desertDunes => 'Desert Dunes',
    Biome.mountainForest => 'Mountain Forest',
    Biome.cityRuins => 'City Ruins',
    Biome.savanna => 'Savanna',
    Biome.frozenPeaks => 'Frozen Peaks',
    Biome.sea => 'Open Sea',
  };

  String get description => switch (this) {
    Biome.grassPlains => 'Open fields, rocky ridges, a winding river.',
    Biome.snowTundra => 'Frozen ground, snow-capped peaks, an icy river.',
    Biome.desertDunes => 'Sun-scorched dunes carved by a dry canyon.',
    Biome.mountainForest => 'Dense pine-covered peaks and a rushing river.',
    Biome.cityRuins => 'Collapsed towers and rubble-choked streets.',
    Biome.savanna => 'Golden grassland, acacia stands, a dry river.',
    Biome.frozenPeaks => 'Sheer ice-clad summits above a frozen crevasse.',
    Biome.sea => 'Open water studded with reefs - the fleet closes in.',
  };

  BiomePalette get palette => switch (this) {
    Biome.grassPlains => const BiomePalette(
      groundTop: Color(0xFF2f4a33),
      groundMid: Color(0xFF3c5a3f),
      groundBottom: Color(0xFF2a4230),
      ridgeLight: Color(0xFF7d8a94),
      ridgeDark: Color(0xFF44505c),
      capColor: Color(0xFFEFF6FA),
      highGround: ObstacleKind.mountain,
      crossing: ObstacleKind.river,
      hasTrees: false,
    ),
    Biome.snowTundra => const BiomePalette(
      groundTop: Color(0xFFe4edf2),
      groundMid: Color(0xFFccdae3),
      groundBottom: Color(0xFFaec0cc),
      ridgeLight: Color(0xFFf7fbfd),
      ridgeDark: Color(0xFF8fa3b0),
      capColor: Color(0xFFFFFFFF),
      highGround: ObstacleKind.mountain,
      crossing: ObstacleKind.river,
      hasTrees: false,
    ),
    Biome.desertDunes => const BiomePalette(
      groundTop: Color(0xFFcfa15c),
      groundMid: Color(0xFFdbb476),
      groundBottom: Color(0xFFb8863f),
      ridgeLight: Color(0xFFe8c98a),
      ridgeDark: Color(0xFF9c6c34),
      capColor: Color(0xFFf0dcae),
      highGround: ObstacleKind.dune,
      crossing: ObstacleKind.valley,
      hasTrees: false,
    ),
    Biome.mountainForest => const BiomePalette(
      groundTop: Color(0xFF223a24),
      groundMid: Color(0xFF2c4a2e),
      groundBottom: Color(0xFF1c3020),
      ridgeLight: Color(0xFF6b7a6d),
      ridgeDark: Color(0xFF39463a),
      capColor: Color(0xFFd8e0d8),
      highGround: ObstacleKind.mountain,
      crossing: ObstacleKind.river,
      hasTrees: true,
    ),
    Biome.cityRuins => const BiomePalette(
      groundTop: Color(0xFF4a4d52),
      groundMid: Color(0xFF3a3d42),
      groundBottom: Color(0xFF25272b),
      ridgeLight: Color(0xFF8a8d92),
      ridgeDark: Color(0xFF35373b),
      capColor: Color(0xFFb8bcc2),
      // Collapsed high-rise rubble uses the mountain shape/paint routine.
      highGround: ObstacleKind.mountain,
      // A bombed-out trench cutting through the streets.
      crossing: ObstacleKind.valley,
      hasTrees: false,
    ),
    Biome.savanna => const BiomePalette(
      groundTop: Color(0xFFc9a63d),
      groundMid: Color(0xFFb3922f),
      groundBottom: Color(0xFF8f7124),
      ridgeLight: Color(0xFFd8c07a),
      ridgeDark: Color(0xFF7a5f28),
      capColor: Color(0xFFe8d69a),
      // Rocky termite-mound outcrops use the dune shape/paint routine.
      highGround: ObstacleKind.dune,
      // A dry, seasonal river cutting across the grassland.
      crossing: ObstacleKind.river,
      hasTrees: true,
    ),
    Biome.frozenPeaks => const BiomePalette(
      groundTop: Color(0xFFcfe6f2),
      groundMid: Color(0xFFa9cddf),
      groundBottom: Color(0xFF7ea6bc),
      ridgeLight: Color(0xFFffffff),
      ridgeDark: Color(0xFF4d7690),
      capColor: Color(0xFFFFFFFF),
      highGround: ObstacleKind.mountain,
      // A frozen crevasse, rendered with the same winding-ribbon routine.
      crossing: ObstacleKind.river,
      hasTrees: false,
    ),
    Biome.sea => const BiomePalette(
      groundTop: Color(0xFF1f6f8a),
      groundMid: Color(0xFF155a75),
      groundBottom: Color(0xFF0b3d52),
      ridgeLight: Color(0xFF6fcbd9),
      ridgeDark: Color(0xFF0d3040),
      // Reefs/islets poking above the waterline, tinted sandy-green instead
      // of snow-capped.
      capColor: Color(0xFFcbd98a),
      highGround: ObstacleKind.mountain,
      // A strong current/channel, rendered with the winding-ribbon routine.
      crossing: ObstacleKind.river,
      hasTrees: false,
    ),
  };
}
