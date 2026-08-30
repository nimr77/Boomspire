import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../../../core/combat/unit_kind.dart';
import '../../../core/rendering/procedural_image.dart';

/// Procedurally paints the friendly unit "2D object models" - soldier, tank,
/// light vehicle and aircraft - all sharing the home base's cyan livery
/// (see `kHomeAccentColor`) so they read as "ours" at a glance, cached
/// after first generation.
class AllySpriteFactory {
  static Sprite? _soldier;
  static Sprite? _tank;
  static Sprite? _lightVehicle;
  static Sprite? _aircraft;
  static Sprite? _rocketBarrage;
  static Sprite? _antiTank;
  static Sprite? _antiAir;
  static Sprite? _stealthBomber;
  static Sprite? _drone;
  static const _hull = Color(0xFF2B3A42);

  static const _hullDark = Color(0xFF172126);
  static const _accent = Color(0xFF00E5FF);
  AllySpriteFactory._();

  static Future<Sprite> aircraft() async {
    final cached = _aircraft;
    if (cached != null) return cached;
    final image = await renderToImage(50, 50, _paintAircraft);
    return _aircraft = Sprite(image);
  }

  static Future<Sprite> antiAir() async {
    final cached = _antiAir;
    if (cached != null) return cached;
    final image = await renderToImage(48, 48, _paintAntiAir);
    return _antiAir = Sprite(image);
  }

  static Future<Sprite> antiTank() async {
    final cached = _antiTank;
    if (cached != null) return cached;
    final image = await renderToImage(48, 48, _paintAntiTank);
    return _antiTank = Sprite(image);
  }

  static Future<Sprite> drone() async {
    final cached = _drone;
    if (cached != null) return cached;
    final image = await renderToImage(42, 42, _paintDrone);
    return _drone = Sprite(image);
  }

  static Future<Sprite> lightVehicle() async {
    final cached = _lightVehicle;
    if (cached != null) return cached;
    final image = await renderToImage(46, 46, _paintLightVehicle);
    return _lightVehicle = Sprite(image);
  }

  static Future<Sprite> rocketBarrage() async {
    final cached = _rocketBarrage;
    if (cached != null) return cached;
    final image = await renderToImage(50, 50, _paintRocketBarrage);
    return _rocketBarrage = Sprite(image);
  }

  static Future<Sprite> soldier() async {
    final cached = _soldier;
    if (cached != null) return cached;
    final image = await renderToImage(48, 48, _paintSoldier);
    return _soldier = Sprite(image);
  }

  static Future<Sprite> spriteFor(UnitKind kind) => switch (kind) {
    UnitKind.soldier => soldier(),
    UnitKind.tank => tank(),
    UnitKind.lightVehicle => lightVehicle(),
    UnitKind.aircraft => aircraft(),
    UnitKind.rocketBarrage => rocketBarrage(),
    UnitKind.antiTankSoldier => antiTank(),
    UnitKind.antiAirSoldier => antiAir(),
    UnitKind.stealthBomber => stealthBomber(),
    UnitKind.drone => drone(),
    _ => throw ArgumentError('No ally sprite for $kind'),
  };

  static Future<Sprite> stealthBomber() async {
    final cached = _stealthBomber;
    if (cached != null) return cached;
    final image = await renderToImage(54, 54, _paintStealthBomber);
    return _stealthBomber = Sprite(image);
  }

  /// Every [UnitKind] this factory has art for - lets a merged unit
  /// component fall back to the other side's factory for a kind that was
  /// only ever painted for one side (e.g. an invader-only Attack Plane).
  static bool supports(UnitKind kind) => switch (kind) {
    UnitKind.soldier ||
    UnitKind.tank ||
    UnitKind.lightVehicle ||
    UnitKind.aircraft ||
    UnitKind.rocketBarrage ||
    UnitKind.antiTankSoldier ||
    UnitKind.antiAirSoldier ||
    UnitKind.stealthBomber ||
    UnitKind.drone => true,
    _ => false,
  };

  static Future<Sprite> tank() async {
    final cached = _tank;
    if (cached != null) return cached;
    final image = await renderToImage(54, 54, _paintTank);
    return _tank = Sprite(image);
  }

  static void _paintAircraft(Canvas canvas) {
    const size = 50.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.7, height: size * 0.22),
      Paint()..color = const Color(0x40000000),
    );

    final wingPath = Path()
      ..moveTo(center.dx, center.dy - size * 0.4)
      ..lineTo(center.dx + size * 0.46, center.dy + size * 0.34)
      ..lineTo(center.dx + size * 0.1, center.dy + size * 0.2)
      ..lineTo(center.dx, center.dy + size * 0.4)
      ..lineTo(center.dx - size * 0.1, center.dy + size * 0.2)
      ..lineTo(center.dx - size * 0.46, center.dy + size * 0.34)
      ..close();
    canvas.drawPath(
      wingPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFCFD8DC), _hull],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: size * 0.4)),
    );
    canvas.drawPath(
      wingPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _accent.withValues(alpha: 0.8),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, -size * 0.06),
        width: size * 0.13,
        height: size * 0.28,
      ),
      Paint()..color = const Color(0xFF1a1c20),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, -size * 0.1),
        width: size * 0.08,
        height: size * 0.14,
      ),
      Paint()..color = _accent.withValues(alpha: 0.9),
    );

    for (final dx in [-size * 0.12, size * 0.12]) {
      canvas.drawCircle(
        center.translate(dx, size * 0.36),
        size * 0.06,
        Paint()
          ..color = _accent.withValues(alpha: 0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  static void _paintAntiAir(Canvas canvas) {
    const size = 48.0;
    const center = Offset(size / 2, size / 2);
    const weaponAccent = Color(0xFFFFB300);

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, size * 0.3),
        width: size * 0.5,
        height: size * 0.18,
      ),
      Paint()..color = const Color(0x59000000),
    );

    // Legs - narrow, close-set rectangles directly under the torso instead
    // of a pair of splayed-out ovals (which read as bug legs).
    for (final dx in [-size * 0.075, size * 0.075]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, size * 0.28),
            width: size * 0.1,
            height: size * 0.26,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = _hullDark,
      );
    }

    // Torso - shoulders-wider-than-hips trapezoid, reads as a person
    // instead of a uniform blob.
    final torsoPath = Path()
      ..moveTo(center.dx - size * 0.26, center.dy - size * 0.2)
      ..lineTo(center.dx + size * 0.26, center.dy - size * 0.2)
      ..lineTo(center.dx + size * 0.17, center.dy + size * 0.2)
      ..lineTo(center.dx - size * 0.17, center.dy + size * 0.2)
      ..close();
    canvas.drawPath(
      torsoPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [_hull, _hullDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(torsoPath.getBounds()),
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size * 0.18),
      Offset(center.dx, center.dy + size * 0.18),
      Paint()
        ..color = weaponAccent.withValues(alpha: 0.7)
        ..strokeWidth = 2,
    );

    // Shoulder pads instead of flanking circles.
    for (final dx in [-size * 0.24, size * 0.24]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, -size * 0.18),
            width: size * 0.13,
            height: size * 0.1,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = _hullDark,
      );
    }

    // Backpack-mounted launcher, tilted skyward.
    final launcher = Paint()
      ..color = const Color(0xFF2b2b2b)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center.translate(size * 0.04, -size * 0.12),
      center.translate(size * 0.36, -size * 0.5),
      launcher,
    );
    canvas.drawCircle(
      center.translate(size * 0.36, -size * 0.5),
      size * 0.06,
      Paint()..color = weaponAccent,
    );

    canvas.drawCircle(
      center.translate(0, -size * 0.3),
      size * 0.16,
      Paint()..color = _hullDark,
    );
    canvas.drawCircle(
      center.translate(0, -size * 0.32),
      size * 0.14,
      Paint()..color = _hull,
    );
    final visorRect = Rect.fromCenter(
      center: center.translate(0, -size * 0.3),
      width: size * 0.22,
      height: size * 0.05,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(visorRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFF0d1a1e),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: visorRect.center.translate(-visorRect.width * 0.22, -0.6),
          width: visorRect.width * 0.32,
          height: visorRect.height * 0.5,
        ),
        const Radius.circular(1),
      ),
      Paint()..color = weaponAccent.withValues(alpha: 0.9),
    );
  }

  static void _paintAntiTank(Canvas canvas) {
    const size = 48.0;
    const center = Offset(size / 2, size / 2);
    const weaponAccent = Color(0xFFFF5252);

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, size * 0.3),
        width: size * 0.5,
        height: size * 0.18,
      ),
      Paint()..color = const Color(0x59000000),
    );

    // Legs - narrow, close-set rectangles directly under the torso instead
    // of a pair of splayed-out ovals (which read as bug legs).
    for (final dx in [-size * 0.075, size * 0.075]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, size * 0.28),
            width: size * 0.1,
            height: size * 0.26,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = _hullDark,
      );
    }

    // Torso - shoulders-wider-than-hips trapezoid, reads as a person
    // instead of a uniform blob.
    final torsoPath = Path()
      ..moveTo(center.dx - size * 0.26, center.dy - size * 0.2)
      ..lineTo(center.dx + size * 0.26, center.dy - size * 0.2)
      ..lineTo(center.dx + size * 0.17, center.dy + size * 0.2)
      ..lineTo(center.dx - size * 0.17, center.dy + size * 0.2)
      ..close();
    canvas.drawPath(
      torsoPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [_hull, _hullDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(torsoPath.getBounds()),
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size * 0.18),
      Offset(center.dx, center.dy + size * 0.18),
      Paint()
        ..color = weaponAccent.withValues(alpha: 0.7)
        ..strokeWidth = 2,
    );

    // Shoulder pads instead of flanking circles.
    for (final dx in [-size * 0.24, size * 0.24]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, -size * 0.18),
            width: size * 0.13,
            height: size * 0.1,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = _hullDark,
      );
    }

    // Shoulder-mounted rocket tube, levelled at the ground.
    final tube = Paint()
      ..color = const Color(0xFF2b2b2b)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center.translate(-size * 0.02, -size * 0.14),
      center.translate(size * 0.44, -size * 0.24),
      tube,
    );
    canvas.drawCircle(
      center.translate(size * 0.44, -size * 0.24),
      size * 0.07,
      Paint()..color = weaponAccent,
    );

    canvas.drawCircle(
      center.translate(0, -size * 0.3),
      size * 0.16,
      Paint()..color = _hullDark,
    );
    canvas.drawCircle(
      center.translate(0, -size * 0.32),
      size * 0.14,
      Paint()..color = _hull,
    );
    final visorRect = Rect.fromCenter(
      center: center.translate(0, -size * 0.3),
      width: size * 0.22,
      height: size * 0.05,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(visorRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFF0d1a1e),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: visorRect.center.translate(-visorRect.width * 0.22, -0.6),
          width: visorRect.width * 0.32,
          height: visorRect.height * 0.5,
        ),
        const Radius.circular(1),
      ),
      Paint()..color = weaponAccent.withValues(alpha: 0.9),
    );
  }

  /// Small straight-wing UAV silhouette (Reaper/Predator-style) - long
  /// high-aspect wings and a V-tail instead of the delta wings shared by
  /// [_paintAircraft]/attack-plane kinds, so it reads as a distinct, cheap
  /// drone rather than a smaller fighter jet. Flies the exact same
  /// strafing-run AI as the other plane-body kinds (see
  /// `UnitKind.drone.bodyType`).
  static void _paintDrone(Canvas canvas) {
    const size = 42.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.5, height: size * 0.7),
      Paint()..color = const Color(0x33000000),
    );

    // Long straight wings.
    final wingRect = Rect.fromCenter(
      center: center,
      width: size * 0.86,
      height: size * 0.12,
    );
    canvas.drawRect(
      wingRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [_hull, _hullDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(wingRect),
    );
    canvas.drawRect(
      wingRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _accent.withValues(alpha: 0.7),
    );

    // Slender fuselage running nose-to-tail.
    final fuselageRect = Rect.fromCenter(
      center: center,
      width: size * 0.16,
      height: size * 0.78,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(fuselageRect, const Radius.circular(6)),
      Paint()
        ..shader = const LinearGradient(
          colors: [_hull, _hullDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(fuselageRect),
    );

    // Inverted V-tail.
    final tailPath = Path()
      ..moveTo(center.dx, center.dy + size * 0.3)
      ..lineTo(center.dx - size * 0.16, center.dy + size * 0.39)
      ..lineTo(center.dx - size * 0.05, center.dy + size * 0.3)
      ..close()
      ..moveTo(center.dx, center.dy + size * 0.3)
      ..lineTo(center.dx + size * 0.16, center.dy + size * 0.39)
      ..lineTo(center.dx + size * 0.05, center.dy + size * 0.3)
      ..close();
    canvas.drawPath(tailPath, Paint()..color = _hullDark);

    // Sensor ball under the nose.
    canvas.drawCircle(
      center.translate(0, -size * 0.34),
      size * 0.07,
      Paint()..color = const Color(0xFF1a1c20),
    );
    canvas.drawCircle(
      center.translate(0, -size * 0.34),
      size * 0.045,
      Paint()..color = _accent.withValues(alpha: 0.9),
    );

    // Pusher-prop hub at the tail.
    canvas.drawCircle(
      center.translate(0, size * 0.36),
      size * 0.05,
      Paint()..color = const Color(0xFF1a1c20),
    );
  }

  static void _paintLightVehicle(Canvas canvas) {
    const size = 46.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.8, height: size * 0.26),
      Paint()..color = const Color(0x40000000),
    );

    final bodyRect = Rect.fromCenter(
      center: center,
      width: size * 0.56,
      height: size * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      Paint()
        ..shader = const LinearGradient(
          colors: [_hull, _hullDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bodyRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _accent.withValues(alpha: 0.8),
    );

    // Windshield.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -size * 0.14),
          width: size * 0.32,
          height: size * 0.16,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = _accent.withValues(alpha: 0.55),
    );

    // Roof-mounted gun.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, size * 0.06),
          width: size * 0.08,
          height: size * 0.26,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF1a1c20),
    );

    // Wheels - small flush rectangles tucked against the body's edge,
    // instead of free-floating circles bulging past the silhouette.
    for (final dy in [-size * 0.22, size * 0.22]) {
      for (final dx in [-size * 0.3, size * 0.3]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center.translate(dx, dy),
              width: size * 0.12,
              height: size * 0.2,
            ),
            const Radius.circular(2),
          ),
          Paint()..color = const Color(0xFF0d0d0d),
        );
      }
    }
  }

  static void _paintRocketBarrage(Canvas canvas) {
    const size = 50.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.86, height: size * 0.3),
      Paint()..color = const Color(0x40000000),
    );

    final bodyRect = Rect.fromCenter(
      center: center.translate(0, size * 0.1),
      width: size * 0.62,
      height: size * 0.56,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)),
      Paint()
        ..shader = const LinearGradient(
          colors: [_hull, _hullDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bodyRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _accent.withValues(alpha: 0.8),
    );

    // Rocket-pod cluster mounted on the back.
    final podRect = Rect.fromCenter(
      center: center.translate(0, -size * 0.22),
      width: size * 0.5,
      height: size * 0.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(podRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF37474F),
    );
    for (final dx in [-size * 0.16, 0.0, size * 0.16]) {
      canvas.drawCircle(
        center.translate(dx, -size * 0.22),
        size * 0.06,
        Paint()..color = _accent.withValues(alpha: 0.9),
      );
    }

    // Wheel-wells - flush rectangles instead of free-floating circles, so
    // the chassis reads as a vehicle rather than a bug's legs.
    for (final dy in [-size * 0.06, size * 0.32]) {
      for (final dx in [-size * 0.32, size * 0.32]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center.translate(dx, dy),
              width: size * 0.14,
              height: size * 0.22,
            ),
            const Radius.circular(2),
          ),
          Paint()..color = const Color(0xFF0d0d0d),
        );
      }
    }
  }

  static void _paintSoldier(Canvas canvas) {
    const size = 48.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, size * 0.3),
        width: size * 0.5,
        height: size * 0.18,
      ),
      Paint()..color = const Color(0x59000000),
    );

    // Legs - narrow, close-set rectangles directly under the torso instead
    // of a pair of splayed-out ovals (which read as bug legs).
    for (final dx in [-size * 0.075, size * 0.075]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, size * 0.28),
            width: size * 0.1,
            height: size * 0.26,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = _hullDark,
      );
    }

    // Torso - shoulders-wider-than-hips trapezoid, reads as a person
    // instead of a uniform blob.
    final torsoPath = Path()
      ..moveTo(center.dx - size * 0.26, center.dy - size * 0.2)
      ..lineTo(center.dx + size * 0.26, center.dy - size * 0.2)
      ..lineTo(center.dx + size * 0.17, center.dy + size * 0.2)
      ..lineTo(center.dx - size * 0.17, center.dy + size * 0.2)
      ..close();
    canvas.drawPath(
      torsoPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [_hull, _hullDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(torsoPath.getBounds()),
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size * 0.18),
      Offset(center.dx, center.dy + size * 0.18),
      Paint()
        ..color = _accent.withValues(alpha: 0.7)
        ..strokeWidth = 2,
    );

    // Shoulder pads instead of flanking circles.
    for (final dx in [-size * 0.24, size * 0.24]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, -size * 0.18),
            width: size * 0.13,
            height: size * 0.1,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = _hullDark,
      );
    }

    // Rifle - shouldered, angled forward from near one shoulder instead of
    // slicing across the whole body like a stray limb.
    final rifle = Paint()
      ..color = const Color(0xFF1a1a1a)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center.translate(size * 0.14, -size * 0.12),
      center.translate(size * 0.34, -size * 0.46),
      rifle,
    );

    canvas.drawCircle(
      center.translate(0, -size * 0.3),
      size * 0.16,
      Paint()..color = _hullDark,
    );
    canvas.drawCircle(
      center.translate(0, -size * 0.32),
      size * 0.14,
      Paint()..color = _hull,
    );
    final visorRect = Rect.fromCenter(
      center: center.translate(0, -size * 0.3),
      width: size * 0.22,
      height: size * 0.05,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(visorRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFF0d1a1e),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: visorRect.center.translate(-visorRect.width * 0.22, -0.6),
          width: visorRect.width * 0.32,
          height: visorRect.height * 0.5,
        ),
        const Radius.circular(1),
      ),
      Paint()..color = _accent.withValues(alpha: 0.9),
    );
  }

  // Neutral stealth-gray livery (not team-tinted, unlike the other ally
  // sprites) - team ownership is shown by `TeamStripeMarkerComponent`
  // instead, so this exact shape/color can be shared with the enemy
  // roster's version (see `EnemySpriteFactory._paintStealthBomber`).
  static void _paintStealthBomber(Canvas canvas) {
    const size = 54.0;
    const center = Offset(size / 2, size / 2);

    // Flying-wing silhouette - no separate fuselage/tail, just one swept
    // boomerang, like a real B-2 Spirit.
    final wingPath = Path()
      ..moveTo(center.dx, center.dy - size * 0.12)
      ..lineTo(center.dx + size * 0.48, center.dy + size * 0.34)
      ..lineTo(center.dx + size * 0.3, center.dy + size * 0.4)
      ..lineTo(center.dx, center.dy + size * 0.16)
      ..lineTo(center.dx - size * 0.3, center.dy + size * 0.4)
      ..lineTo(center.dx - size * 0.48, center.dy + size * 0.34)
      ..close();
    canvas.drawPath(
      wingPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF3A3F44), Color(0xFF0D0F10)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: size * 0.4)),
    );
    canvas.drawPath(
      wingPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x33000000),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, -size * 0.02),
        width: size * 0.1,
        height: size * 0.16,
      ),
      Paint()..color = const Color(0xFF1A1C1E),
    );
  }

  static void _paintTank(Canvas canvas) {
    const size = 54.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.85, height: size * 0.3),
      Paint()..color = const Color(0x40000000),
    );

    // Flush tracks along the hull's edges instead of one big rounded band
    // (which read as a pair of circles peeking out past the sides).
    for (final dx in [-size * 0.36, size * 0.36]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, 0),
            width: size * 0.14,
            height: size * 0.66,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFF1a1c20),
      );
    }

    // Hull.
    final hullRect = Rect.fromCenter(
      center: center,
      width: size * 0.68,
      height: size * 0.46,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hullRect, const Radius.circular(8)),
      Paint()
        ..shader = const LinearGradient(
          colors: [_hull, _hullDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(hullRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hullRect, const Radius.circular(8)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _accent.withValues(alpha: 0.8),
    );

    // Turret.
    canvas.drawCircle(
      center.translate(0, -size * 0.04),
      size * 0.2,
      Paint()
        ..shader = const LinearGradient(colors: [_hull, _hullDark])
            .createShader(Rect.fromCircle(center: center, radius: size * 0.2)),
    );
    canvas.drawCircle(
      center.translate(0, -size * 0.04),
      size * 0.2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _accent,
    );

    // Barrel.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -size * 0.34),
          width: size * 0.1,
          height: size * 0.4,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF1a1c20),
    );
  }
}
