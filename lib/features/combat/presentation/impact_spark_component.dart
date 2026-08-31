import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_impact_sparks.dart';
import 'util/spawn_impact_sparks.dart';

/// Small spark burst where a bullet lands, reinforcing hits with extra
/// visual feedback beyond the tracer itself.
class ImpactSparkComponent extends PositionComponent {
  static const _duration = 0.18;

  final Color color;
  double _age = 0;
  late final List<Vector2> _sparks;

  ImpactSparkComponent({required Vector2 position, required this.color})
    : super(position: position, anchor: Anchor.center, priority: 24);

  @override
  Future<void> onLoad() async {
    _sparks = spawnImpactSparks();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    paintImpactSparks(canvas, t: t, color: color, sparks: _sparks);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
