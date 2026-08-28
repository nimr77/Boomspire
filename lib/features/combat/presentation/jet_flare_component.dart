import 'dart:ui';

import 'package:flame/components.dart';

/// Bright engine exhaust flame trailing a plane-kind unit while it flies -
/// distinct from the condensation-streak `VaporConeComponent` (which every
/// swoop-style flyer already gets), this is specifically the jet's own
/// engine fire/afterburner glow.
class JetFlareComponent extends PositionComponent {
  static const _duration = 0.22;

  final double flareAngle;

  /// True while the plane is in "attack mode" (within boost range of its
  /// engaged target, see `_planeBoostRangeCells`) - renders a longer, blue
  /// afterburner streak instead of the plain yellow/orange exhaust flame.
  final bool boosted;
  double _age = 0;

  JetFlareComponent({
    required Vector2 position,
    required double angle,
    this.boosted = false,
  }) : flareAngle = angle,
       super(position: position, anchor: Anchor.center, priority: 4);

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final fade = 1 - t;
    final length = (boosted ? 24 : 16) + t * (boosted ? 10 : 6);

    canvas.save();
    canvas.rotate(flareAngle + 3.14159);
    final path = Path()
      ..moveTo(0, -4)
      ..lineTo(length, 0)
      ..lineTo(0, 4)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Color.lerp(
          boosted ? const Color(0xFF80D8FF) : const Color(0xFFFFF176),
          boosted ? const Color(0x001565C0) : const Color(0x00FF7043),
          t,
        )!.withValues(alpha: 0.85 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
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
