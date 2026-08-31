import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_track_mark.dart';

/// A tread print stamped into the ground behind a heavy (tracked) vehicle -
/// unlike the light vehicle's [DustPuffComponent] this lingers for a while
/// so a driven-over path visibly reads as tracks on the map.
class TrackMarkComponent extends PositionComponent {
  static const _duration = 7.0;

  double _age = 0;

  TrackMarkComponent({required Vector2 position, required double angle})
    : super(
        position: position,
        anchor: Anchor.center,
        angle: angle,
        priority: -1,
      );

  @override
  void render(Canvas canvas) =>
      paintTrackMark(canvas, age: _age, duration: _duration);

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
