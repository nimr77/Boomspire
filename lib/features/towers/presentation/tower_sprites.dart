import 'dart:math';

import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../../../core/rendering/procedural_image.dart';
import '../domain/models/building_type.dart';
import '../domain/models/tower_type.dart';
import '../domain/models/unit_type.dart';

/// Procedurally paints tower base plates and turrets - our "2D object
/// models" for towers and buildings, cached per [UnitType] so art is
/// generated once.
class TowerSpriteFactory {
  static final Map<UnitType, Sprite> _baseCache = {};

  static final Map<UnitType, Sprite> _turretCache = {};
  TowerSpriteFactory._();

  /// The faction color for this unit type - reused for turret art and for
  /// the ground fire-pulse effect when it shoots.
  static Color accentColor(UnitType type) => switch (type) {
    TowerType.rocket => const Color(0xFFFF6B35),
    TowerType.cannon => const Color(0xFFFFC107),
    TowerType.antiAir => const Color(0xFF7C4DFF),
    TowerType.machineGun => const Color(0xFF4FC3F7),
    TowerType.laser => const Color(0xFFFF3D9A),
    TowerType.rocketSilo => const Color(0xFFFF8A00),
    TowerType.artilleryBunker => const Color(0xFF8D6E63),
    TowerType.sam => const Color(0xFF00E5FF),
    BuildingType.techLab => const Color(0xFF1DE9B6),
    BuildingType.commandPost => const Color(0xFFFFD54A),
    BuildingType.trainingCenter => const Color(0xFF66BB6A),
    BuildingType.warFactory => const Color(0xFFB0BEC5),
    BuildingType.goldMine => const Color(0xFFFFB300),
    _ => const Color(0xFFBDBDBD),
  };

  static Future<Sprite> base(UnitType type) async {
    final cached = _baseCache[type];
    if (cached != null) return cached;
    final image = await renderToImage(64, 64, (c) => _paintBase(c, type));
    return _baseCache[type] = Sprite(image);
  }

  static Future<Sprite> turret(UnitType type) async {
    final cached = _turretCache[type];
    if (cached != null) return cached;
    final image = await renderToImage(48, 48, (c) => _paintTurret(c, type));
    return _turretCache[type] = Sprite(image);
  }

  static void _paintAntiAirTurret(Canvas canvas, Offset center) {
    // Twin angled flak barrels pointed skyward, each with a muzzle collar.
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(side * -0.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(0, -14), width: 5, height: 24),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF35284f),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(0, -25), width: 6.5, height: 5),
          const Radius.circular(1.5),
        ),
        Paint()..color = const Color(0xFF1a1420),
      );
      canvas.restore();
    }
    // Ammo feed box at the base - reads closer to a real flak/AA mount.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, 9), width: 12, height: 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF2b2436),
    );
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF9575CD), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: center, radius: 11)),
    );
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF7C4DFF),
    );
    _paintViewhole(canvas, center.translate(-6, -1));
  }

  static void _paintArtilleryBunkerTurret(Canvas canvas, Offset center) {
    // A short, wide reinforced barrel on a squat mount - heavier and more
    // armored-looking than the Siege Cannon, built to endure return fire.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, -6), width: 20, height: 20),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF4e4038),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -18),
          width: 12,
          height: 20,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF6d5a4e),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, -28), width: 14, height: 6),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF2b2318),
    );
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF8D6E63), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: center, radius: 13)),
    );
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF8D6E63),
    );
    _paintViewhole(canvas, center.translate(-7, 6));
  }

  static void _paintBase(Canvas canvas, UnitType type) {
    // Support buildings get a distinct building silhouette instead of the
    // round weapon-mount plate every combat tower shares.
    if (type == BuildingType.trainingCenter) {
      _paintTrainingCenterBase(canvas);
      return;
    }
    if (type == BuildingType.warFactory) {
      _paintWarFactoryBase(canvas);
      return;
    }

    const center = Offset(32, 32);
    final accent = accentColor(type);

    final path = Path();
    for (var i = 0; i < 6; i++) {
      final a = pi / 6 + i * pi / 3;
      final p = Offset(center.dx + cos(a) * 28, center.dy + sin(a) * 28);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();

    canvas.drawShadow(path, const Color(0xFF000000), 4, false);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF636d7a), Color(0xFF20242a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center, radius: 30)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withValues(alpha: 0.85),
    );
    canvas.drawCircle(center, 10, Paint()..color = const Color(0xFF11151a));
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = accent,
    );
  }

  static void _paintCannonTurret(Canvas canvas, Offset center) {
    // A single thick barrel with a muzzle brake - reads as "heavy artillery".
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, -9), width: 16, height: 34),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF454b52),
    );
    for (final dy in [-24.0, -20.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(0, dy),
            width: 21,
            height: 3,
          ),
          const Radius.circular(1.5),
        ),
        Paint()..color = const Color(0xFF23262b),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, -24), width: 19, height: 8),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF23262b),
    );
    canvas.drawCircle(
      center,
      14,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF8d8060), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: center, radius: 14)),
    );
    canvas.drawCircle(
      center,
      14,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFFC107),
    );
    _paintViewhole(canvas, center.translate(8, 6));
  }

  static void _paintCommandPostTurret(Canvas canvas, Offset center) {
    // A rotating comms antenna array with a beacon light - reads as a
    // command/support structure that coordinates rather than fires.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, -8), width: 4, height: 20),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF3a3220),
    );
    for (final side in [-1.0, 1.0]) {
      canvas.drawLine(
        center.translate(0, -18),
        center.translate(side * 8, -12),
        Paint()
          ..color = const Color(0xFFFFD54A)
          ..strokeWidth = 1.5,
      );
    }
    canvas.drawCircle(
      center.translate(0, -19),
      2.4,
      Paint()..color = const Color(0xFFFFF176),
    );
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFb89a4a), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: center, radius: 12)),
    );
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFFD54A),
    );
    _paintViewhole(canvas, center.translate(0, 7));
  }

  static void _paintGoldMineTurret(Canvas canvas, Offset center) {
    // A small ore headframe (A-frame + pulley wheel) over a pile of gold
    // nuggets - reads as an economy structure, not a weapon.
    for (final side in [-1.0, 1.0]) {
      canvas.drawLine(
        center.translate(side * 8, 10),
        center.translate(0, -16),
        Paint()
          ..color = const Color(0xFF6d4c1f)
          ..strokeWidth = 2.5,
      );
    }
    canvas.drawCircle(
      center.translate(0, -16),
      3,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFFD54A),
    );
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFD54A), Color(0xFF7a5a1a)],
        ).createShader(Rect.fromCircle(center: center, radius: 12)),
    );
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFFB300),
    );
    // Gold nuggets scattered at the base.
    for (final offset in [
      const Offset(-6, 8),
      const Offset(5, 9),
      const Offset(0, 11),
    ]) {
      canvas.drawCircle(
        center.translate(offset.dx, offset.dy),
        2.2,
        Paint()..color = const Color(0xFFFFE082),
      );
    }
  }

  static void _paintLaserTurret(Canvas canvas, Offset center) {
    // A single slender emitter rod ending in a crystal lens - reads as an
    // energy weapon rather than a ballistic one.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, -12), width: 6, height: 26),
        const Radius.circular(3),
      ),
      Paint()
        ..shader =
            const LinearGradient(colors: [Color(0xFF3a1030), Color(0xFF120810)])
                .createShader(
                  Rect.fromCenter(
                    center: center.translate(0, -12),
                    width: 6,
                    height: 26,
                  ),
                ),
    );
    for (final r in [7.0, 4.0]) {
      canvas.drawCircle(
        center.translate(0, -24),
        r,
        Paint()
          ..color = const Color(0xFFFF3D9A)
              .withValues(alpha: r == 7.0 ? 0.35 : 0.9)
          ..maskFilter = r == 7.0
              ? const MaskFilter.blur(BlurStyle.normal, 4)
              : null,
      );
    }
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF7a2a55), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: center, radius: 12)),
    );
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFF3D9A),
    );
    _paintViewhole(canvas, center.translate(-6, 6));
  }

  static void _paintMachineGunTurret(Canvas canvas, Offset center) {
    // Three-barrel rotary cluster - reads closer to a real minigun/gatling.
    for (final dx in [-6.0, 0.0, 6.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, -9),
            width: 4.5,
            height: 25,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF2b2f36),
      );
    }
    canvas.drawCircle(
      center.translate(0, -18),
      6,
      Paint()..color = const Color(0xFF1a1c20),
    );
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF7a8592), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: center, radius: 12)),
    );
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF4FC3F7),
    );
    _paintViewhole(canvas, center.translate(0, 7));
  }

  static void _paintRocketSiloTurret(Canvas canvas, Offset center) {
    // A boxy multi-tube launcher angled skyward - reads as long-range
    // artillery built to reach big/armored targets rather than a nimble gun.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -10), width: 22, height: 26),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF4a3a28),
    );
    for (final dx in [-6.0, 0.0, 6.0]) {
      canvas.drawCircle(
        Offset(dx, -18),
        3.2,
        Paint()..color = const Color(0xFF1c1712),
      );
      canvas.drawCircle(
        Offset(dx, -18),
        3.2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFFFF8A00),
      );
    }
    canvas.restore();
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF8a5a2a), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: center, radius: 13)),
    );
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFF8A00),
    );
    _paintViewhole(canvas, center.translate(0, 8));
  }

  static void _paintRocketTurret(Canvas canvas, Offset center) {
    // Three-tube launch pod - reads closer to a real MLRS battery.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, -8), width: 20, height: 32),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF3a3f47),
    );
    for (final dx in [-6.0, 0.0, 6.0]) {
      canvas.drawCircle(
        Offset(center.dx + dx, center.dy - 22),
        4.2,
        Paint()..color = const Color(0xFF1a1c20),
      );
      canvas.drawCircle(
        Offset(center.dx + dx, center.dy - 22),
        4.2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFF6b6f76),
      );
    }
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF9a4a34), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: center, radius: 13)),
    );
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFF6B35),
    );
    _paintViewhole(canvas, center.translate(-7, 6));
  }

  static void _paintSamTurret(Canvas canvas, Offset center) {
    // A single missile tube tilted skyward on a launcher box - reads as a
    // dedicated long-range AA site rather than a rapid-fire flak mount.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -15), width: 6, height: 26),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF1c3d42),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -27), width: 4, height: 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFFF6B35),
    );
    canvas.restore();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, 8), width: 16, height: 9),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF16282b),
    );
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF2b6e78), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: center, radius: 11)),
    );
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF00E5FF),
    );
    _paintViewhole(canvas, center.translate(-6, 6));
  }

  static void _paintTechLabTurret(Canvas canvas, Offset center) {
    // A tilted dish on a mast - reads as a sensor/uplink structure rather
    // than a weapon, since it never actually fires.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, -6), width: 4, height: 18),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF2b2f36),
    );
    canvas.save();
    canvas.translate(center.dx, center.dy - 16);
    canvas.rotate(-0.4);
    canvas.drawArc(
      Rect.fromCenter(center: Offset.zero, width: 22, height: 16),
      3.4,
      3.0,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF1DE9B6),
    );
    canvas.drawCircle(Offset.zero, 2, Paint()..color = const Color(0xFFE0FFF6));
    canvas.restore();
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF2e6b5f), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: center, radius: 12)),
    );
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF1DE9B6),
    );
    _paintViewhole(canvas, center.translate(0, 7));
  }

  /// A low barracks building with a peaked roof, door and windows - reads
  /// as a muster point rather than a gun emplacement.
  static void _paintTrainingCenterBase(Canvas canvas) {
    const accent = Color(0xFF66BB6A);
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(10, 28, 44, 28),
      const Radius.circular(4),
    );
    canvas.drawShadow(
      Path()..addRRect(body),
      const Color(0xFF000000),
      4,
      false,
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF4c7a4f), Color(0xFF20242a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(body.outerRect),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withValues(alpha: 0.85),
    );

    final roof = Path()
      ..moveTo(6, 28)
      ..lineTo(32, 9)
      ..lineTo(58, 28)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFF2f4a31));
    canvas.drawPath(
      roof,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = accent,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(27, 40, 10, 16),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF11151a),
    );
    for (final dx in [-14.0, 14.0]) {
      final window = Rect.fromCenter(
        center: Offset(32 + dx, 37),
        width: 8,
        height: 8,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(window, const Radius.circular(1.5)),
        Paint()..color = const Color(0xFF11151a),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(window, const Radius.circular(1.5)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = accent,
      );
    }
  }

  static void _paintTrainingCenterTurret(Canvas canvas, Offset center) {
    // A small flagpole with a fluttering pennant - reads as a barracks/muster
    // point rather than a weapon, since it never actually fires; it just
    // musters fresh soldiers to send out.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, -6), width: 3, height: 20),
        const Radius.circular(1.5),
      ),
      Paint()..color = const Color(0xFF2b2f36),
    );
    final flag = Path()
      ..moveTo(center.dx + 1.5, center.dy - 15)
      ..lineTo(center.dx + 11, center.dy - 12)
      ..lineTo(center.dx + 1.5, center.dy - 8)
      ..close();
    canvas.drawPath(flag, Paint()..color = const Color(0xFF66BB6A));
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF4c7a4f), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: center, radius: 12)),
    );
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF66BB6A),
    );
    _paintViewhole(canvas, center.translate(0, 7));
  }

  static void _paintTurret(Canvas canvas, UnitType type) {
    const center = Offset(24, 24);
    switch (type) {
      case TowerType.machineGun:
        _paintMachineGunTurret(canvas, center);
      case TowerType.rocket:
        _paintRocketTurret(canvas, center);
      case TowerType.cannon:
        _paintCannonTurret(canvas, center);
      case TowerType.antiAir:
        _paintAntiAirTurret(canvas, center);
      case TowerType.laser:
        _paintLaserTurret(canvas, center);
      case TowerType.rocketSilo:
        _paintRocketSiloTurret(canvas, center);
      case TowerType.artilleryBunker:
        _paintArtilleryBunkerTurret(canvas, center);
      case TowerType.sam:
        _paintSamTurret(canvas, center);
      case BuildingType.techLab:
        _paintTechLabTurret(canvas, center);
      case BuildingType.commandPost:
        _paintCommandPostTurret(canvas, center);
      case BuildingType.trainingCenter:
        _paintTrainingCenterTurret(canvas, center);
      case BuildingType.warFactory:
        _paintWarFactoryTurret(canvas, center);
      case BuildingType.goldMine:
        _paintGoldMineTurret(canvas, center);
    }
  }

  /// A small crew vision-slit with a glass glint, reused by every turret so
  /// each unit reads as crewed/piloted hardware rather than a bare emitter.
  static void _paintViewhole(Canvas canvas, Offset center) {
    final slit = Rect.fromCenter(center: center, width: 6, height: 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(slit, const Radius.circular(1.2)),
      Paint()..color = const Color(0xFF0d2b33),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: slit.center.translate(-1.2, -0.6),
          width: 2.2,
          height: 1.2,
        ),
        const Radius.circular(0.6),
      ),
      Paint()..color = const Color(0xCCBEEFFF),
    );
  }

  /// A wide corrugated workshop with a roll-up bay door - reads as heavy
  /// industry rather than a gun emplacement.
  static void _paintWarFactoryBase(Canvas canvas) {
    const accent = Color(0xFFB0BEC5);
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6, 26, 52, 30),
      const Radius.circular(3),
    );
    canvas.drawShadow(
      Path()..addRRect(body),
      const Color(0xFF000000),
      4,
      false,
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF607d8b), Color(0xFF20242a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(body.outerRect),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withValues(alpha: 0.85),
    );

    for (var x = 12.0; x <= 52; x += 8) {
      canvas.drawLine(
        Offset(x, 26),
        Offset(x, 19),
        Paint()
          ..color = const Color(0xFF37474F)
          ..strokeWidth = 2,
      );
    }

    const door = Rect.fromLTWH(22, 40, 20, 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(door, const Radius.circular(2)),
      Paint()..color = const Color(0xFF11151a),
    );
    for (var y = door.top + 3; y < door.bottom; y += 4) {
      canvas.drawLine(
        Offset(door.left + 2, y),
        Offset(door.right - 2, y),
        Paint()
          ..color = accent.withValues(alpha: 0.5)
          ..strokeWidth = 1,
      );
    }
  }

  static void _paintWarFactoryTurret(Canvas canvas, Offset center) {
    // A stubby smokestack with a crane arm - reads as heavy industry rather
    // than a weapon, since it never actually fires; it just rolls out
    // vehicles and aircraft.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(-5, -8), width: 7, height: 22),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF78909C),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(-5, -20), width: 9, height: 5),
        const Radius.circular(1.5),
      ),
      Paint()..color = const Color(0xFF37474F),
    );
    canvas.drawLine(
      center.translate(2, -14),
      center.translate(12, -18),
      Paint()
        ..color = const Color(0xFFB0BEC5)
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF607d8b), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: center, radius: 12)),
    );
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFB0BEC5),
    );
    _paintViewhole(canvas, center.translate(0, 7));
  }
}
