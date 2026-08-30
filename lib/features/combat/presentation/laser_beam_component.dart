import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// A short, fast electric-plasma pulse that races from a firer to its
/// target then blooms into a flare on arrival - the visual for
/// [WeaponType.laser]. Deliberately compact (a short bolt with a jagged
/// electric kink, not one long solid beam line) and glow-heavy so it reads
/// as crackling energy rather than a laser-pointer streak. Damage is
/// already applied by the firer the instant this spawns - this is purely
/// the visual.
class LaserBeamComponent extends PositionComponent {
  static const _travelDuration = 0.07;
  static const _flareDuration = 0.13;
  static const _pulseLength = 18.0;

  final Vector2 start;
  final Vector2 end;
  final Color color;
  final double _kinkSide;
  double _age = 0;

  LaserBeamComponent({
    required this.start,
    required this.end,
    required this.color,
  })  : _kinkSide = Random().nextBool() ? 1.0 : -1.0,
        super(priority: 22);

  @override
  void render(Canvas canvas) {
    final direction = end - start;
    final length = direction.length;
    if (length <= 0) return;
    final unit = direction.normalized();
    final perp = Vector2(-unit.y, unit.x);

    final travelT = (_age / _travelDuration).clamp(0.0, 1.0);
    final flareT =
        ((_age - _travelDuration) / _flareDuration).clamp(0.0, 1.0);
    const core = Color(0xFFF4FFFF);
    final electricAccent = Color.lerp(color, const Color(0xFFB388FF), 0.5)!;

    if (travelT < 1.0) {
      // Soft blurred glow bathing the path already traveled - a blurred
      // ambient backdrop instead of a hard-edged laser line.
      final traveled = start + unit * (length * travelT);
      canvas.drawLine(
        Offset(start.x, start.y),
        Offset(traveled.x, traveled.y),
        Paint()
          ..color = color.withValues(alpha: 0.16 * (1 - travelT * 0.5))
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );

      // The pulse itself: a short bright bolt riding the travel front, with
      // one jagged kink for a lightning-like electric flicker.
      final head = traveled;
      final tail = head - unit * _pulseLength;
      final kink =
          tail + unit * (_pulseLength * 0.4) + perp * (4 * _kinkSide);
      final bolt = Path()
        ..moveTo(tail.x, tail.y)
        ..lineTo(kink.x, kink.y)
        ..lineTo(head.x, head.y);
      canvas.drawPath(
        bolt,
        Paint()
          ..color = electricAccent.withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawPath(
        bolt,
        Paint()
          ..color = core.withValues(alpha: 0.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Muzzle flare - a quick bright burst right at the firer, faded out
    // over the first half of the travel.
    _flare(
      canvas,
      start,
      (1 - travelT / 0.5).clamp(0.0, 1.0),
      electricAccent,
      core,
    );

    // Impact flare - blooms once the pulse lands, then fades.
    if (_age >= _travelDuration) {
      _flare(
        canvas,
        end,
        1 - flareT,
        electricAccent,
        core,
        scale: 1 + flareT * 0.7,
      );
    }
  }

  void _flare(
    Canvas canvas,
    Vector2 at,
    double strength,
    Color accent,
    Color core, {
    double scale = 1.0,
  }) {
    if (strength <= 0) return;
    final center = Offset(at.x, at.y);
    canvas.drawCircle(
      center,
      8 * scale,
      Paint()
        ..color = accent.withValues(alpha: 0.4 * strength)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      center,
      3 * scale,
      Paint()..color = core.withValues(alpha: 0.9 * strength),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _travelDuration + _flareDuration) removeFromParent();
  }
}
