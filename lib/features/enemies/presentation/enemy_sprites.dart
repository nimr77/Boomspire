import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../../../core/combat/unit_kind.dart';
import '../../../core/rendering/procedural_image.dart';

/// Procedurally paints the green-soldier "2D object models" - a regular
/// soldier and a bulkier, red-trimmed heavy soldier - cached after first
/// generation.
class EnemySpriteFactory {
  static Sprite? _soldier;

  static Sprite? _heavy;
  static Sprite? _helicopter;
  static Sprite? _tank;
  static Sprite? _attackPlane;
  static Sprite? _artilleryBarrage;
  static Sprite? _rocketBarrage;
  static Sprite? _antiAirVehicle;
  EnemySpriteFactory._();

  static Future<Sprite> antiAirVehicle() async {
    final cached = _antiAirVehicle;
    if (cached != null) return cached;
    final image = await renderToImage(52, 52, _paintAntiAirVehicle);
    return _antiAirVehicle = Sprite(image);
  }

  static Future<Sprite> artilleryBarrage() async {
    final cached = _artilleryBarrage;
    if (cached != null) return cached;
    final image = await renderToImage(52, 52, _paintArtilleryBarrage);
    return _artilleryBarrage = Sprite(image);
  }

  static Future<Sprite> attackPlane() async {
    final cached = _attackPlane;
    if (cached != null) return cached;
    final image = await renderToImage(50, 50, _paintAttackPlane);
    return _attackPlane = Sprite(image);
  }

  static Future<Sprite> heavySoldier() async {
    final cached = _heavy;
    if (cached != null) return cached;
    final image = await renderToImage(60, 60, (c) => _paint(c, heavy: true));
    return _heavy = Sprite(image);
  }

  static Future<Sprite> helicopter() async {
    final cached = _helicopter;
    if (cached != null) return cached;
    final image = await renderToImage(46, 46, _paintHelicopter);
    return _helicopter = Sprite(image);
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
    final image = await renderToImage(48, 48, (c) => _paint(c, heavy: false));
    return _soldier = Sprite(image);
  }

  static Future<Sprite> spriteFor(UnitKind kind) => switch (kind) {
    UnitKind.soldier => soldier(),
    UnitKind.heavySoldier => heavySoldier(),
    UnitKind.tank => tank(),
    UnitKind.helicopter => helicopter(),
    UnitKind.attackPlane => attackPlane(),
    UnitKind.artilleryBarrage => artilleryBarrage(),
    UnitKind.rocketBarrage => rocketBarrage(),
    UnitKind.antiAirVehicle => antiAirVehicle(),
    _ => throw ArgumentError('No enemy sprite for $kind'),
  };

  /// Every [UnitKind] this factory has art for - lets a merged unit
  /// component fall back to the other side's factory for a kind that was
  /// only ever painted for one side (e.g. a player-built Helicopter).
  static bool supports(UnitKind kind) => switch (kind) {
    UnitKind.soldier ||
    UnitKind.heavySoldier ||
    UnitKind.tank ||
    UnitKind.helicopter ||
    UnitKind.attackPlane ||
    UnitKind.artilleryBarrage ||
    UnitKind.rocketBarrage ||
    UnitKind.antiAirVehicle => true,
    _ => false,
  };

  static Future<Sprite> tank() async {
    final cached = _tank;
    if (cached != null) return cached;
    final image = await renderToImage(54, 54, _paintTank);
    return _tank = Sprite(image);
  }

  static void _paint(Canvas canvas, {required bool heavy}) {
    final size = heavy ? 60.0 : 48.0;
    final center = Offset(size / 2, size / 2);
    final bodyColor = heavy ? const Color(0xFF33691E) : const Color(0xFF4C7A2A);
    final darkColor = heavy ? const Color(0xFF1B3D0F) : const Color(0xFF2E4B18);

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
        Paint()..color = darkColor,
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
        ..shader = LinearGradient(
          colors: [bodyColor, darkColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(torsoPath.getBounds()),
    );
    if (heavy) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(0, size * 0.02),
            width: size * 0.22,
            height: size * 0.24,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF263A17),
      );
    }
    canvas.drawLine(
      Offset(center.dx, center.dy - size * 0.18),
      Offset(center.dx, center.dy + size * 0.18),
      Paint()
        ..color = darkColor
        ..strokeWidth = 2,
    );

    // Shoulder pads - rectangular armor plates instead of round dots (round
    // "spots" on a rounded green body read as insect markings).
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
        Paint()..color = heavy ? const Color(0xFFB71C1C) : darkColor,
      );
    }

    // Rifle - shouldered, angled forward from near one shoulder instead of
    // slicing across the whole body like a stray limb.
    final riflePaint = Paint()
      ..color = const Color(0xFF1a1a1a)
      ..strokeWidth = heavy ? 4 : 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center.translate(size * 0.14, -size * 0.12),
      center.translate(size * 0.34, -size * 0.46),
      riflePaint,
    );

    canvas.drawCircle(
      center.translate(0, -size * 0.3),
      size * 0.17,
      Paint()..color = darkColor,
    );
    canvas.drawCircle(
      center.translate(0, -size * 0.32),
      size * 0.15,
      Paint()..color = bodyColor,
    );
    // Visor viewhole - a dark slit with a glass glint so the face reads at
    // a glance, instead of a flat helmet color block.
    final visorRect = Rect.fromCenter(
      center: center.translate(0, -size * 0.3),
      width: size * 0.22,
      height: size * 0.05,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(visorRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFF0d1a06),
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
      Paint()..color = const Color(0xCCBEEFFF),
    );
  }

  static void _paintAntiAirVehicle(Canvas canvas) {
    const size = 52.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.85, height: size * 0.3),
      Paint()..color = const Color(0x40000000),
    );

    // Flush tracks along the hull's edges - narrow rectangles instead of
    // round pods, so they read as treads rather than a pair of bug legs.
    for (final dx in [-size * 0.3, size * 0.3]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, size * 0.06),
            width: size * 0.13,
            height: size * 0.6,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFF1a1c20),
      );
    }

    // Hull.
    final hullRect = Rect.fromCenter(
      center: center,
      width: size * 0.58,
      height: size * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hullRect, const Radius.circular(6)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF78909C), Color(0xFF263238)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(hullRect),
    );

    // Twin flak barrels, angled skyward instead of a tank's single
    // forward-pointed barrel - the visual cue that this vehicle shoots air
    // targets too.
    for (final dx in [-size * 0.08, size * 0.08]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, -size * 0.3),
            width: size * 0.07,
            height: size * 0.32,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF2b2f36),
      );
    }

    // Radar dish on the deck.
    canvas.drawCircle(
      center.translate(0, -size * 0.02),
      size * 0.13,
      Paint()..color = const Color(0xFF37474F),
    );
    canvas.drawCircle(
      center.translate(0, -size * 0.02),
      size * 0.08,
      Paint()..color = const Color(0xFFFFCA28).withValues(alpha: 0.85),
    );

    canvas.drawCircle(
      center.translate(0, size * 0.16),
      size * 0.045,
      Paint()..color = const Color(0xFFFFF59D),
    );
  }

  static void _paintArtilleryBarrage(Canvas canvas) {
    const size = 52.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.85, height: size * 0.3),
      Paint()..color = const Color(0x40000000),
    );

    // Flush tracks along the hull's edges - narrow rectangles instead of
    // round pods, so they read as treads rather than a pair of bug legs.
    for (final dx in [-size * 0.3, size * 0.3]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, size * 0.08),
            width: size * 0.14,
            height: size * 0.58,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFF1a1c20),
      );
    }

    final hullRect = Rect.fromCenter(
      center: center,
      width: size * 0.6,
      height: size * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hullRect, const Radius.circular(6)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF5D4037), Color(0xFF2E1A16)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(hullRect),
    );

    // Mortar deck - a mounting plate the barrels visibly sit on, instead
    // of bare tubes sprouting straight off the hull like antennae.
    final deckRect = Rect.fromCenter(
      center: center.translate(0, -size * 0.16),
      width: size * 0.5,
      height: size * 0.16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(deckRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF3E2723),
    );

    // Three stubby mortar barrels fanned out on the deck.
    for (final dx in [-size * 0.14, 0.0, size * 0.14]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, -size * 0.24),
            width: size * 0.1,
            height: size * 0.22,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF3E2723),
      );
    }
    canvas.drawCircle(
      center.translate(0, size * 0.02),
      size * 0.05,
      Paint()..color = const Color(0xFFE53935),
    );
  }

  static void _paintAttackPlane(Canvas canvas) {
    const size = 50.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.7, height: size * 0.22),
      Paint()..color = const Color(0x40000000),
    );

    // Delta wings - a single sweeping F-35-ish silhouette.
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
          colors: [Color(0xFFB0BEC5), Color(0xFF37474F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: size * 0.4)),
    );

    // Canopy.
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
      Paint()..color = const Color(0xCC00E5FF),
    );

    // Twin engine afterburner glow at the tail - reads as "fast/hostile".
    for (final dx in [-size * 0.12, size * 0.12]) {
      canvas.drawCircle(
        center.translate(dx, size * 0.36),
        size * 0.07,
        Paint()
          ..color = const Color(0xFFFF7043)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(
        center.translate(dx, size * 0.36),
        size * 0.035,
        Paint()..color = const Color(0xFFFFF3C4),
      );
    }
  }

  static void _paintHelicopter(Canvas canvas) {
    const size = 46.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.9, height: size * 0.28),
      Paint()..color = const Color(0x40000000),
    );

    // Tail boom, thinning toward the tail rotor.
    final boomPath = Path()
      ..moveTo(center.dx - size * 0.1, center.dy - size * 0.08)
      ..lineTo(center.dx - size * 0.46, center.dy - size * 0.03)
      ..lineTo(center.dx - size * 0.46, center.dy + size * 0.05)
      ..lineTo(center.dx - size * 0.1, center.dy + size * 0.1)
      ..close();
    canvas.drawPath(boomPath, Paint()..color = const Color(0xFF37474F));

    // Tail fin + tail-rotor blur disc.
    canvas.drawCircle(
      center.translate(-size * 0.46, 0),
      size * 0.1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0x99B0BEC5),
    );

    // Fuselage body (rounder/bulkier than the old fixed-wing shape).
    final bodyRect = Rect.fromCenter(
      center: center.translate(size * 0.06, 0),
      width: size * 0.5,
      height: size * 0.34,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(14)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF616161), Color(0xFF263238)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bodyRect),
    );

    // Landing skids.
    for (final dy in [size * 0.19, size * 0.24]) {
      canvas.drawLine(
        center.translate(-size * 0.1, dy),
        center.translate(size * 0.24, dy),
        Paint()
          ..color = const Color(0xFF1a1c20)
          ..strokeWidth = 1.6,
      );
    }

    // Cockpit bubble at the nose (red - hostile), with a canopy frame and
    // glass glint instead of a flat glow dot.
    final cockpit = center.translate(size * 0.26, -size * 0.02);
    canvas.drawCircle(
      cockpit,
      size * 0.15,
      Paint()..color = const Color(0xFF1a1c20),
    );
    canvas.drawCircle(
      cockpit,
      size * 0.12,
      Paint()..color = const Color(0xFFE53935),
    );
    canvas.drawCircle(
      cockpit,
      size * 0.15,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF9E9E9E),
    );
    canvas.drawCircle(
      cockpit.translate(-size * 0.04, -size * 0.04),
      size * 0.03,
      Paint()..color = const Color(0xCCFFFFFF),
    );

    // Rotor mast stub - the actual spinning blades are a separate live
    // child component layered on top so they can rotate every frame.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -size * 0.16),
          width: size * 0.06,
          height: size * 0.14,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF1a1c20),
    );
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
          colors: [Color(0xFF5D4037), Color(0xFF2E1A16)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bodyRect),
    );

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
        Paint()..color = const Color(0xFFE53935),
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

  static void _paintTank(Canvas canvas) {
    const size = 54.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.85, height: size * 0.3),
      Paint()..color = const Color(0x40000000),
    );

    // Flush tracks along the hull's edges - narrow rectangles instead of
    // round pods, so they read as treads rather than a pair of bug legs.
    for (final dx in [-size * 0.3, size * 0.3]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, size * 0.06),
            width: size * 0.13,
            height: size * 0.6,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFF1a1c20),
      );
    }

    // Hull.
    final hullRect = Rect.fromCenter(
      center: center,
      width: size * 0.58,
      height: size * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hullRect, const Radius.circular(6)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF6D4C41), Color(0xFF3E2723)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(hullRect),
    );

    // Turret + barrel, pointed "up" (forward) by default.
    canvas.drawCircle(
      center,
      size * 0.19,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF8D6E63), Color(0xFF3E2723)],
        ).createShader(Rect.fromCircle(center: center, radius: size * 0.19)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -size * 0.28),
          width: size * 0.09,
          height: size * 0.34,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF2b2f36),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, size * 0.02),
          width: size * 0.1,
          height: size * 0.04,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFE53935),
    );

    // Headlight - small warm beacon on the hull front, doubles as the
    // "alive" light other vehicle types also carry.
    canvas.drawCircle(
      center.translate(0, size * 0.16),
      size * 0.045,
      Paint()..color = const Color(0xFFFFF59D),
    );
  }
}
