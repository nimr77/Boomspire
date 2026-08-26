import 'package:flutter/material.dart' show Color;

import 'obstacle_kind.dart';

/// A selectable map theme. Drives ground color palette, which high-ground
/// obstacle shape is used, whether a river or dry valley cuts the map, and
/// whether decorative trees are scattered.
enum Biome { grassPlains, snowTundra, desertDunes, mountainForest }

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
  };

  String get description => switch (this) {
    Biome.grassPlains => 'Open fields, rocky ridges, a winding river.',
    Biome.snowTundra => 'Frozen ground, snow-capped peaks, an icy river.',
    Biome.desertDunes => 'Sun-scorched dunes carved by a dry canyon.',
    Biome.mountainForest => 'Dense pine-covered peaks and a rushing river.',
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
  };
}
