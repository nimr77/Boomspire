import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_laser_beam.dart';
import 'util/spawn_laser_beam_kink_side.dart';

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
  }) : _kinkSide = spawnLaserBeamKinkSide(),
       super(priority: 22);

  @override
  void render(Canvas canvas) {
    paintLaserBeam(
      canvas,
      start: start,
      end: end,
      color: color,
      kinkSide: _kinkSide,
      age: _age,
      travelDuration: _travelDuration,
      flareDuration: _flareDuration,
      pulseLength: _pulseLength,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _travelDuration + _flareDuration) removeFromParent();
  }
}
