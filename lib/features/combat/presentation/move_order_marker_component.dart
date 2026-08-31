import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_move_order_marker.dart';

/// Pulsing pin shown at the point a player-controlled unit was just
/// ordered to move to - stays up (see `BoomspireGame._syncMoveOrderMarker`)
/// for as long as that unit is selected and still traveling there, and
/// disappears once it arrives or gets a new order.
class MoveOrderMarkerComponent extends PositionComponent {
  final Color color;

  double _phase = 0;
  MoveOrderMarkerComponent({required super.position, required this.color})
    : super(anchor: Anchor.center, priority: 20);

  @override
  void render(Canvas canvas) =>
      paintMoveOrderMarker(canvas, color: color, phase: _phase);

  @override
  void update(double dt) {
    super.update(dt);
    _phase += dt * 4;
  }
}
