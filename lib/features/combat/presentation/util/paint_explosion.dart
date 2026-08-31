import 'dart:ui';

import 'spawn_explosion_embers.dart';

/// Paints one frame of an `ExplosionComponent`: the expanding flash ring
/// (while [t] < 0.4) plus the scattering embers, at animation progress [t]
/// (0..1), age [age], and total [duration].
void paintExplosion(
  Canvas canvas, {
  required double t,
  required double age,
  required double duration,
  required double radius,
  required List<ExplosionEmber> embers,
}) {
  if (t < 0.4) {
    final ringT = t / 0.4;
    final ringRadius = radius * (0.3 + ringT * 0.9);
    canvas.drawCircle(
      Offset.zero,
      ringRadius,
      Paint()
        ..color = Color.lerp(
          const Color(0xFFFFF3C4),
          const Color(0x00FF6A00),
          ringT,
        )!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * (1 - ringT),
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 0.35 * (1 - ringT * 0.6),
      Paint()
        ..color = Color.lerp(
          const Color(0xFFFFFFFF),
          const Color(0x00FFAE42),
          ringT,
        )!,
    );
  }

  for (final ember in embers) {
    if (age < ember.delay) continue;
    final emberT = ((age - ember.delay) / (duration - ember.delay)).clamp(
      0.0,
      1.0,
    );
    final pos = ember.velocity * emberT;
    final opacity = (1 - emberT).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(pos.x, pos.y),
      4 * (1 - emberT * 0.6),
      Paint()
        ..color = Color.lerp(
          const Color(0xFFFFC069),
          const Color(0xFF3E2110),
          emberT,
        )!.withValues(alpha: opacity),
    );
  }
}
