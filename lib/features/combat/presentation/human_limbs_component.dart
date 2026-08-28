import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

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
  void render(Canvas canvas) {
    // Flame renders every component in a top-left-origin 0..size box
    // regardless of anchor, so "centered on the body" requires explicitly
    // offsetting by half the hull size here rather than drawing around
    // (0, 0) - otherwise the limbs render a half-hull-width/height away
    // from the actual torso.
    final cx = size.x / 2;
    final cy = size.y / 2;
    final legSwing = sin(_phase) * size.y * 0.16;
    final legPaint = Paint()
      ..color = const Color(0xFF2A2D31)
      ..strokeWidth = size.x * 0.09
      ..strokeCap = StrokeCap.round;
    final hipY = cy + size.y * 0.28;
    canvas.drawLine(
      Offset(cx - size.x * 0.1, hipY),
      Offset(cx - size.x * 0.1 + legSwing * 0.3, hipY + size.y * 0.34),
      legPaint,
    );
    canvas.drawLine(
      Offset(cx + size.x * 0.1, hipY),
      Offset(cx + size.x * 0.1 - legSwing * 0.3, hipY + size.y * 0.34),
      legPaint,
    );

    if (_fireFlash > 0) {
      final armPaint = Paint()
        ..color = accent.withValues(
          alpha: (_fireFlash / _fireFlashDuration).clamp(0.0, 1.0),
        )
        ..strokeWidth = size.x * 0.08
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx + size.x * 0.12, cy - size.y * 0.05),
        Offset(cx + size.x * 0.42, cy - size.y * 0.22),
        armPaint,
      );
    }
  }

  void setPhase(double phase) => _phase = phase;

  @override
  void update(double dt) {
    super.update(dt);
    if (_fireFlash > 0) _fireFlash = (_fireFlash - dt).clamp(0.0, 1.0);
  }
}
