import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Rocket impact: a bright expanding flash ring plus scattering embers,
/// scaled to the tower's splash radius.
class ExplosionComponent extends PositionComponent {
  static const _duration = 0.6;

  final double radius;
  double _age = 0;
  late final List<_Ember> _embers;
  ExplosionComponent({required Vector2 position, required this.radius})
    : super(position: position, anchor: Anchor.center, priority: 30);

  @override
  Future<void> onLoad() async {
    final rnd = Random();
    _embers = List.generate(16, (_) {
      final a = rnd.nextDouble() * 2 * pi;
      final speed = radius * (0.6 + rnd.nextDouble() * 1.2);
      return _Ember(Vector2(cos(a), sin(a)) * speed, rnd.nextDouble() * 0.15);
    });
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);

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

    for (final ember in _embers) {
      if (_age < ember.delay) continue;
      final emberT = ((_age - ember.delay) / (_duration - ember.delay)).clamp(
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

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}

class _Ember {
  final Vector2 velocity;
  final double delay;
  _Ember(this.velocity, this.delay);
}
