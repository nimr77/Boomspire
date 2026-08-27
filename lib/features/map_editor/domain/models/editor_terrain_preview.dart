import '../../../../core/pathfinding/grid.dart';
import '../../../terrain/domain/models/biome.dart';
import '../../../terrain/domain/models/obstacle_kind.dart';

/// A rasterized preview of a [MapDraft]'s terrain - the editor canvas draws
/// this directly; it's also the basis for a real `TerrainMap` once a draft
/// gains home/spawn placement in a later editor pass.
class EditorTerrainPreview {
  final Grid grid;

  /// Per-cell obstacle flavor (null = open ground), same shape as [grid].
  final List<List<ObstacleKind?>> obstacleKinds;
  final Biome biome;

  const EditorTerrainPreview({
    required this.grid,
    required this.obstacleKinds,
    required this.biome,
  });
}
