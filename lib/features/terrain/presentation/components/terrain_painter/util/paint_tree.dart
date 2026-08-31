import 'dart:math';
import 'dart:ui' as ui;

import '../../../../../../core/pathfinding/grid.dart';
import '../../../../domain/models/biome.dart';
import 'paint_acacia_canopy.dart';
import 'paint_conifer_canopy.dart';
import 'paint_desert_tree.dart';
import 'paint_forest_canopy.dart';
import 'paint_palm_canopy.dart';
import 'paint_round_canopy.dart';
import 'paint_scorched_tree.dart';
import 'paint_snowy_canopy.dart';

/// Trees adapt their silhouette/color to the biome they're planted on
/// (whether scattered automatically or hand-placed via the map editor's
/// Tree brush) instead of always looking like the same grassland tree - a
/// snow-capped conifer on the tundra reads very differently from a
/// scorched dead tree in the ruins.
void paintTree(
  ui.Canvas canvas,
  Grid grid,
  int col,
  int row,
  Random rnd,
  Biome biome, {
  double sway = 0,
}) {
  final cx =
      col * grid.cellSize + grid.cellSize / 2 + (rnd.nextDouble() - 0.5) * 8;
  final cy =
      row * grid.cellSize + grid.cellSize / 2 + (rnd.nextDouble() - 0.5) * 8;
  final scale = 0.7 + rnd.nextDouble() * 0.5;
  // Only the canopy leans with [sway] - the shadow stays put so the
  // trunk still reads as planted in the ground while it tips.
  final canopyCx = cx + sway;

  // Ground shadow first, so the canopy reads as sitting above the tile.
  canvas.drawOval(
    ui.Rect.fromCenter(
      center: ui.Offset(cx + 3, cy + 9 * scale),
      width: 20 * scale,
      height: 8 * scale,
    ),
    ui.Paint()
      ..color = const ui.Color(0xFF000000).withValues(alpha: 0.22)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3),
  );

  switch (biome) {
    case Biome.mountainForest:
      paintForestCanopy(canvas, canopyCx, cy, scale);
    case Biome.savanna:
      paintAcaciaCanopy(canvas, canopyCx, cy, scale);
    case Biome.snowTundra:
      paintSnowyCanopy(canvas, canopyCx, cy, scale);
    case Biome.frozenPeaks:
      paintConiferCanopy(canvas, canopyCx, cy, scale);
    case Biome.desertDunes:
      paintDesertTree(canvas, canopyCx, cy, scale);
    case Biome.sea:
      paintPalmCanopy(canvas, canopyCx, cy, scale);
    case Biome.cityRuins:
      paintScorchedTree(canvas, canopyCx, cy, scale);
    case Biome.grassPlains:
      paintRoundCanopy(canvas, canopyCx, cy, scale);
    case Biome.snowyGrassland:
      paintSnowyCanopy(canvas, canopyCx, cy, scale);
  }
}
