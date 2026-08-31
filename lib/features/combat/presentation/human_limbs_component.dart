import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_human_limbs.dart';

/// Simple procedural leg/arm-swing overlay for infantry - the flat torso
/// sprite stays fixed, this draws two scissoring "leg" strokes timed to the
/// unit's own bob phase (walk cycle) plus a brief arm/weapon kick stroke
/// whenever [pulseFire] is called, so infantry visibly move their limbs
/// while walking and shooting instead of sliding around as a static image.
class HumanLimbsComponent extends PositionComponent {
  static const _fireFlashDuration = 0.18;
  final Color accent;
  double _phase = 0;

  double _fireFlash = 0;

  HumanLimbsComponent({required Vector2 hullSize, required this.accent})
    : super(
        position: hullSize / 2,
        anchor: Anchor.center,
        size: hullSize,
        priority: 6,
      );

  void pulseFire() => _fireFlash = _fireFlashDuration;

  @override
  void render(Canvas canvas) => paintHumanLimbs(
    canvas,
    size: size,
    accent: accent,
    phase: _phase,
    fireFlash: _fireFlash,
    fireFlashDuration: _fireFlashDuration,
  );

  void setPhase(double phase) => _phase = phase;

  @override
  void update(double dt) {
    super.update(dt);
    if (_fireFlash > 0) _fireFlash = (_fireFlash - dt).clamp(0.0, 1.0);
  }
}
