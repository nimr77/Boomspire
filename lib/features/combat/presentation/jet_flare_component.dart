import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Soft engine-exhaust glow trailing a plane-kind unit while it flies -
/// distinct from the condensation-streak `VaporConeComponent` (which every
/// swoop-style flyer already gets), this is specifically the jet's own
/// engine light. Deliberately a radially-symmetric pulsing glow (fades in
/// then back out) rather than a directional flame/streak shape - reads as
/// a light breathing at the engine instead of a drawn line trailing it.
class JetFlareComponent extends PositionComponent {
  static const _duration = 0.22;

  final double flareAngle;

  /// Tints the outer glow so the flare reads as *that unit's* engine light
  /// (matching the health bar/muzzle flash/fire-pulse accent), not a
  /// generic effect - team.color everywhere else in the game.
  final Color color;

  /// True while the plane is in "attack mode" (within boost range of its
  /// engaged target, see `_planeBoostRangeCells`) - renders a bigger,
  /// brighter afterburner glow instead of the plain resting exhaust light.
  final bool boosted;
  double _age = 0;

  JetFlareComponent({
    required Vector2 position,
    required double angle,
    required this.color,
    this.boosted = false,
  }) : flareAngle = angle,
       super(position: position, anchor: Anchor.center, priority: 4);

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    // Rises to full brightness then fades back out over its short life -
    // "a light feeds in and out" rather than a static line.
    final pulse = sin(t * pi).clamp(0.0, 1.0);
    final baseRadius = boosted ? 9.0 : 6.0;
    final radius = baseRadius + pulse * (boosted ? 7.0 : 4.0);
    final glowAlpha = boosted ? 0.75 : 0.55;

    // Rotating an axis-symmetric glow is a visual no-op, but keeps
    // `flareAngle` a genuine input (callers still pass the facing angle so
    // the light stays anchored at the engine, not just at the component's
    // own position).
    canvas.save();
    canvas.rotate(flareAngle);
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = color.withValues(alpha: glowAlpha * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.7),
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 0.4,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.85 * pulse),
    );
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
