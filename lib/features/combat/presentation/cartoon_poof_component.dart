import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// A silly, non-gory "cartoon pop" for a defeated soldier - a squash pop of
/// cream-colored smoke, a few flailing limb-shaped scraps, and spinning
/// yellow stars, instead of a serious explosion.
class CartoonPoofComponent extends PositionComponent {
  static const _duration = 0.5;

  double _age = 0;
  late final List<_Scrap> _scraps;
  late final List<_Star> _stars;

  CartoonPoofComponent({required Vector2 position})
    : super(position: position, anchor: Anchor.center, priority: 20);

  @override
  Future<void> onLoad() async {
    final rnd = Random();
    _scraps = List.generate(5, (_) {
      final a = rnd.nextDouble() * 2 * pi;
      final speed = 30 + rnd.nextDouble() * 40;
      return _Scrap(
        Vector2(cos(a), sin(a)) * speed,
        rnd.nextDouble() * 2 * pi,
        6 + rnd.nextDouble() * 4,
      );
    });
    _stars = List.generate(4, (i) {
      final a = i * (pi / 2) + rnd.nextDouble() * 0.6;
      return _Star(Vector2(cos(a), sin(a)) * (24 + rnd.nextDouble() * 18));
    });
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final fade = 1 - t;

    // Cream "poof" cloud - a few overlapping fading circles, punchy pop-in
    // then dissolve.
    final puffT = (t / 0.4).clamp(0.0, 1.0);
    final puffRadius = 10 + puffT * 22;
    for (final dx in [-6.0, 0.0, 7.0]) {
      canvas.drawCircle(
        Offset(dx, -dx.abs() * 0.3),
        puffRadius * (0.8 + dx.abs() * 0.01),
        Paint()..color = const Color(0xFFF5F0E6).withValues(alpha: 0.6 * fade),
      );
    }

    for (final scrap in _scraps) {
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

    for (final star in _stars) {
      final pos = star.velocity * t;
      _drawStar(canvas, Offset(pos.x, pos.y), 3 + fade * 2, fade);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }

  void _drawStar(Canvas canvas, Offset center, double r, double alpha) {
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
}

class _Scrap {
  final Vector2 velocity;
  final double spin;
  final double length;
  _Scrap(this.velocity, this.spin, this.length);
}

class _Star {
  final Vector2 velocity;
  _Star(this.velocity);
}
