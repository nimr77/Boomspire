import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Small spark burst where a bullet lands, reinforcing hits with extra
/// visual feedback beyond the tracer itself.
class ImpactSparkComponent extends PositionComponent {
  static const _duration = 0.18;
  static final Random _rnd = Random();

  final Color color;
  double _age = 0;
  late final List<Vector2> _sparks;

  ImpactSparkComponent({required Vector2 position, required this.color})
    : super(position: position, anchor: Anchor.center, priority: 24);

  @override
  Future<void> onLoad() async {
    _sparks = List.generate(6, (_) {
      final a = _rnd.nextDouble() * 2 * pi;
      final speed = 10 + _rnd.nextDouble() * 14;
      return Vector2(cos(a), sin(a)) * speed;
    });
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: (1 - t) * 0.9)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (final spark in _sparks) {
      final p = spark * t;
      canvas.drawLine(Offset(p.x, p.y), Offset(p.x * 0.5, p.y * 0.5), paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
