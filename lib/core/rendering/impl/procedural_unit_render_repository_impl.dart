import 'package:flame/components.dart';

import '../domain/repos/unit_render_repository.dart';

/// The "no external model" backend - always defers to the caller-supplied
/// procedural Canvas sprite. Exists as its own repo (rather than being an
/// implicit default) so it can be selected, tested, and DI'd exactly like
/// the Lottie/Rive backends.
class ProceduralUnitRenderRepositoryImpl implements UnitRenderRepository {
  @override
  Future<PositionComponent> render({
    required String key,
    required Vector2 size,
    required Future<PositionComponent> Function() fallback,
  }) => fallback();
}
