import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_dust_puff.dart';
import 'util/spawn_dust_puff_drift_angle.dart';

/// Light dust kicked up behind a wheeled (light) vehicle - fades quickly
/// and leaves nothing behind, unlike [TrackMarkComponent].
class DustPuffComponent extends PositionComponent {
  static const _duration = 0.6;

  double _age = 0;
  final double _driftAngle = spawnDustPuffDriftAngle();

  DustPuffComponent({required Vector2 position})
    : super(position: position, anchor: Anchor.center, priority: -1);

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    paintDustPuff(canvas, t: t, driftAngle: _driftAngle);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
