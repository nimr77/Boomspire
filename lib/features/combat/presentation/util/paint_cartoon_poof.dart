import 'dart:math';
import 'dart:ui';

import 'cartoon_poof_particles.dart';

/// Paints one frame of a `CartoonPoofComponent`: the cream puff cloud, the
/// flailing scraps, and the spinning stars, at animation progress [t]
/// (0..1) with [fade] = 1 - t.
void paintCartoonPoof(
  Canvas canvas, {
  required double t,
  required double fade,
  required List<CartoonPoofScrap> scraps,
  required List<CartoonPoofStar> stars,
}) {
  final puffT = (t / 0.4).clamp(0.0, 1.0);
  final puffRadius = 10 + puffT * 22;
  for (final dx in [-6.0, 0.0, 7.0]) {
    canvas.drawCircle(
      Offset(dx, -dx.abs() * 0.3),
      puffRadius * (0.8 + dx.abs() * 0.01),
      Paint()..color = const Color(0xFFF5F0E6).withValues(alpha: 0.6 * fade),
    );
  }

  for (final scrap in scraps) {
    final pos = scrap.velocity * t;
    canvas.save();
    canvas.translate(pos.x, pos.y);
    canvas.rotate(scrap.spin * t * 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: scrap.length, height: 3),
        const Radius.circular(1.5),
      ),
      Paint()..color = const Color(0xFF4C7A2A).withValues(alpha: fade),
    );
    canvas.restore();
  }

  for (final star in stars) {
    final pos = star.velocity * t;
    _paintCartoonPoofStar(canvas, Offset(pos.x, pos.y), 3 + fade * 2, fade);
  }
}

void _paintCartoonPoofStar(
  Canvas canvas,
  Offset center,
  double r,
  double alpha,
) {
  final paint = Paint()
    ..color = const Color(0xFFFFD54A).withValues(alpha: alpha);
  final path = Path();
  for (var i = 0; i < 4; i++) {
    final a = i * pi / 2;
    final tip = center.translate(cos(a) * r, sin(a) * r);
    final mid = center.translate(
      cos(a + pi / 4) * r * 0.35,
      sin(a + pi / 4) * r * 0.35,
    );
    if (i == 0) {
      path.moveTo(tip.dx, tip.dy);
    } else {
      path.lineTo(tip.dx, tip.dy);
    }
    path.lineTo(mid.dx, mid.dy);
  }
  path.close();
  canvas.drawPath(path, paint);
}
