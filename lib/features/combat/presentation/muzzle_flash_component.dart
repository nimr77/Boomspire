import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Quick bright flash at a tower's muzzle when it fires, with a few
/// radiating sparks layered on for a punchier shot.
class MuzzleFlashComponent extends PositionComponent {
  static const _duration = 0.09;
  static final Random _rnd = Random();

  double _age = 0;
  late final List<double> _sparkAngles;
  MuzzleFlashComponent({required Vector2 position})
    : super(position: position, anchor: Anchor.center, priority: 25);

  @override
  Future<void> onLoad() async {
    _sparkAngles = List.generate(5, (_) => _rnd.nextDouble() * 2 * pi);
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _duration).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset.zero,
      8 * (1 - t),
      Paint()
        ..color = Color.lerp(
          const Color(0xFFFFF6D8),
          const Color(0x00FFB703),
          t,
        )!,
    );

    final sparkPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFFFFE082),
        const Color(0x00FFB703),
        t,
      )!
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final sparkLength = 12 * (1 - t);
    for (final a in _sparkAngles) {
      canvas.drawLine(
        Offset.zero,
        Offset(cos(a), sin(a)) * sparkLength,
        sparkPaint,
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
