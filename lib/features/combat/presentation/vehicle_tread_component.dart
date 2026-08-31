import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_vehicle_tread.dart';

/// Scrolling tread/wheel-tick overlay drawn along the bottom of a ground
/// vehicle's hull - the flat baked hull sprite can't literally spin its
/// wheels/tracks, so this fakes the same read by sliding a short row of
/// dashes sideways while the vehicle is actually moving (frozen while it
/// stands still), giving wheels/tracks a "feel of moving".
class VehicleTreadComponent extends PositionComponent {
  double _scroll = 0;
  bool moving = false;

  VehicleTreadComponent({required Vector2 hullSize})
    : super(
        position: Vector2(hullSize.x / 2, hullSize.y * 0.82),
        anchor: Anchor.center,
        size: Vector2(hullSize.x * 0.7, hullSize.y * 0.12),
        priority: 6,
      );

  @override
  void render(Canvas canvas) =>
      paintVehicleTread(canvas, size: size, scroll: _scroll);

  @override
  void update(double dt) {
    super.update(dt);
    if (moving) _scroll += dt * 90;
  }
}
