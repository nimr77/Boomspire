import 'dart:ui' as ui;

import 'package:flutter/material.dart' show Colors;

import '../../../../../../core/pathfinding/grid.dart';

/// Highlights every unblocked cell in build mode, tinted green when the
/// selected tower is affordable or red otherwise.
void paintBuildableGridOverlay(
  ui.Canvas canvas,
  Grid grid, {
  required bool canAfford,
}) {
  for (var row = 0; row < grid.rows; row++) {
    for (var col = 0; col < grid.cols; col++) {
      if (grid.blocked[row][col]) continue;
      final cx = col * grid.cellSize;
      final cy = row * grid.cellSize;
      final rect = ui.Rect.fromLTWH(
        cx + 2,
        cy + 2,
        grid.cellSize - 4,
        grid.cellSize - 4,
      );
      canvas.drawRect(
        rect,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = (canAfford ? Colors.greenAccent : Colors.redAccent)
              .withValues(alpha: 0.18),
      );
    }
  }
}
