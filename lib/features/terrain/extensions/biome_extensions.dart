import 'package:flutter/material.dart' show Color;

import '../../../generated/l10n.dart';
import '../domain/enums/biome.dart';
import '../domain/enums/obstacle_kind.dart';
import '../domain/enums/wind_type.dart';
import '../domain/models/biome.dart' show BiomePalette;

extension BiomeExtensions on Biome {
  /// This biome's own natural wind look - what a scene's live weather
  /// renders when a keyframe leaves [WindType] on [WindType.automatic].
  /// This is the biome's *default*, not a hard link: [EnvironmentSettings]
  /// can still override it explicitly on any keyframe.
  WindType get defaultWindType => switch (this) {
    Biome.grassPlains || Biome.savanna => WindType.grassLeaves,
    Biome.mountainForest => WindType.autumnLeaves,
    Biome.snowTundra || Biome.frozenPeaks => WindType.snow,
    Biome.desertDunes => WindType.sand,
    Biome.cityRuins || Biome.sea => WindType.dust,
  };

  String get description => switch (this) {
    Biome.grassPlains => S.current.biomeDescriptionGrassPlains,
    Biome.snowTundra => S.current.biomeDescriptionSnowTundra,
    Biome.desertDunes => S.current.biomeDescriptionDesertDunes,
    Biome.mountainForest => S.current.biomeDescriptionMountainForest,
    Biome.cityRuins => S.current.biomeDescriptionCityRuins,
    Biome.savanna => S.current.biomeDescriptionSavanna,
    Biome.frozenPeaks => S.current.biomeDescriptionFrozenPeaks,
    Biome.sea => S.current.biomeDescriptionSea,
  };

  String get displayName => switch (this) {
    Biome.grassPlains => S.current.biomeNameGrassPlains,
    Biome.snowTundra => S.current.biomeNameSnowTundra,
    Biome.desertDunes => S.current.biomeNameDesertDunes,
    Biome.mountainForest => S.current.biomeNameMountainForest,
    Biome.cityRuins => S.current.biomeNameCityRuins,
    Biome.savanna => S.current.biomeNameSavanna,
    Biome.frozenPeaks => S.current.biomeNameFrozenPeaks,
    Biome.sea => S.current.biomeNameSea,
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
