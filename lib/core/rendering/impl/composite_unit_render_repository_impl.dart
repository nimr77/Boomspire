import 'package:flame/components.dart';

import '../domain/repos/unit_render_repository.dart';
import 'lottie_unit_render_repository_impl.dart';
import 'procedural_unit_render_repository_impl.dart';
import 'rive_unit_render_repository_impl.dart';

/// Default [UnitRenderRepository]: tries a hand-authored Rive model, then a
/// baked Lottie model, else the procedural Canvas fallback - in that
/// priority order, per `key`.
class CompositeUnitRenderRepositoryImpl implements UnitRenderRepository {
  CompositeUnitRenderRepositoryImpl({
    UnitRenderRepository? rive,
    UnitRenderRepository? lottie,
    UnitRenderRepository? procedural,
  }) : _rive = rive ?? RiveUnitRenderRepositoryImpl(),
       _lottie = lottie ?? LottieUnitRenderRepositoryImpl(),
       _procedural = procedural ?? ProceduralUnitRenderRepositoryImpl();

  final UnitRenderRepository _rive;
  final UnitRenderRepository _lottie;
  final UnitRenderRepository _procedural;

  @override
  Future<PositionComponent> render({
    required String key,
    required Vector2 size,
    required Future<PositionComponent> Function() fallback,
  }) {
    return _rive.render(
      key: key,
      size: size,
      fallback: () => _lottie.render(
        key: key,
        size: size,
        fallback: () =>
            _procedural.render(key: key, size: size, fallback: fallback),
      ),
    );
  }
}
