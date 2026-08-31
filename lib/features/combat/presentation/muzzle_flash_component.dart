import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_muzzle_flash.dart';
import 'util/spawn_muzzle_flash_spark_angles.dart';

/// Quick bright flash at a tower's muzzle when it fires, with a few
/// radiating sparks layered on for a punchier shot.
class MuzzleFlashComponent extends PositionComponent {
  static const _duration = 0.09;

  double _age = 0;
  late final List<double> _sparkAngles;
  MuzzleFlashComponent({required Vector2 position})
    : super(position: position, anchor: Anchor.center, priority: 25);

  @override
  Future<void> onLoad() async {
    _sparkAngles = spawnMuzzleFlashSparkAngles();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    paintMuzzleFlash(canvas, t: t, sparkAngles: _sparkAngles);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
