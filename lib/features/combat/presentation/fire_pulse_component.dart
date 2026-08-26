import 'dart:ui';

import 'package:flame/components.dart';

/// A flat ground-level shockwave ring that flashes under a unit the instant
/// it fires, tinted to that unit's faction color. Sized from the shot's
/// power and range so heavier/longer-ranged weapons leave a bigger pulse.
class FirePulseComponent extends PositionComponent {
  FirePulseComponent({
    required Vector2 position,
    required this.color,
    required this.maxRadius,
  }) : super(position: position, anchor: Anchor.center, priority: 2);

  final Color color;
  final double maxRadius;

  double _age = 0;
  static const _duration = 0.32;

  /// Derives a pulse radius from a weapon's range and damage - "the size of
  /// the firing" - clamped to a sane on-screen range.
  static double radiusFor({required double range, required double damage}) {
    return (16 + range * 0.12 + damage * 0.3).clamp(16.0, 90.0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final eased = 1 - (1 - t) * (1 - t);
    final ringRadius = maxRadius * (0.15 + eased * 0.85);
    final fade = 1 - t;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: ringRadius * 2,
        height: ringRadius * 1.1,
      ),
      Paint()
        ..color = color.withValues(alpha: 0.5 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 * fade + 0.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: ringRadius * 1.15,
        height: ringRadius * 0.62,
      ),
      Paint()
        ..color = color.withValues(alpha: 0.16 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }
}
