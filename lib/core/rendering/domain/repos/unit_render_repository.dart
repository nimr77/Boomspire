import 'package:flame/components.dart';

/// Resolves the on-screen visual for a unit/tower/building `key` (e.g.
/// `enemy_tank`, `ally_soldier`, `tower_cannon`) - the single seam
/// presentation components go through instead of picking a rendering
/// backend (procedural Canvas, Lottie, Rive) themselves.
///
/// [fallback] builds the current procedural Canvas sprite for the caller's
/// unit/tower - every implementation must fall back to it when it has no
/// asset (or no working asset) for [key].
abstract class UnitRenderRepository {
  Future<PositionComponent> render({
    required String key,
    required Vector2 size,
    required Future<PositionComponent> Function() fallback,
  });
}
