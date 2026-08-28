import 'package:flutter/material.dart' show Color;

import 'obstacle_kind.dart';

export '../enums/biome.dart';

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

