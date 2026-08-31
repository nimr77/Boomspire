import 'package:flutter/material.dart';

import '../../../domain/models/biome.dart';
import '../../../domain/models/obstacle_kind.dart';

/// Preview color for a rasterized obstacle cell - shared by the map editor
/// canvas and any other read-only terrain preview (e.g. the pre-game
/// placement screen) so they agree on the same look.
Color obstacleColor(ObstacleKind kind, BiomePalette palette) => switch (kind) {
  ObstacleKind.mountain => palette.capColor,
  ObstacleKind.dune => palette.ridgeLight,
  ObstacleKind.river => Colors.blueAccent,
  ObstacleKind.valley => palette.ridgeDark,
  ObstacleKind.lake => Colors.teal.shade300,
  ObstacleKind.lava => Colors.deepOrange.shade600,
  ObstacleKind.volcanicLake => Colors.deepOrange.shade900,
};
