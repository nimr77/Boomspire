import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../map_editor/domain/models/editor_terrain_preview.dart';
import '../../../terrain/domain/models/biome.dart';
import '../../../terrain/presentation/obstacle_color.dart';

/// Lightweight read-only terrain preview (biome gradient + rasterized
/// obstacle cells, no sun/weather) - enough to see the map's shape while
/// picking a starting site.
class SkirmishPlacementDraftPreviewPainter extends CustomPainter {
  final EditorTerrainPreview preview;

  SkirmishPlacementDraftPreviewPainter({required this.preview});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final palette = preview.biome.palette;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, size.height),
          [palette.groundTop, palette.groundMid, palette.groundBottom],
          const [0.0, 0.5, 1.0],
        ),
    );

    final grid = preview.grid;
    if (grid.cols == 0 || grid.rows == 0) return;
    final cellW = size.width / grid.cols;
    final cellH = size.height / grid.rows;
    for (var row = 0; row < grid.rows; row++) {
      for (var col = 0; col < grid.cols; col++) {
        final kind = preview.obstacleKinds[row][col];
        if (kind == null) continue;
        canvas.drawRect(
          Rect.fromLTWH(col * cellW, row * cellH, cellW, cellH),
          Paint()..color = obstacleColor(kind, palette),
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant SkirmishPlacementDraftPreviewPainter oldDelegate,
  ) => oldDelegate.preview != preview;
}
