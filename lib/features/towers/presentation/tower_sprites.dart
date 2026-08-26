import 'dart:math';

import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../../../core/rendering/procedural_image.dart';
import '../domain/models/tower_type.dart';

/// Procedurally paints tower base plates and turrets - our "2D object
/// models" for towers, cached per [TowerType] so art is generated once.
class TowerSpriteFactory {
  static final Map<TowerType, Sprite> _baseCache = {};

  static final Map<TowerType, Sprite> _turretCache = {};
  TowerSpriteFactory._();

  /// The faction color for this tower type - reused for turret art and for
  /// the ground fire-pulse effect when it shoots.
  static Color accentColor(TowerType type) => switch (type) {
    TowerType.rocket => const Color(0xFFFF6B35),
    TowerType.cannon => const Color(0xFFFFC107),
    TowerType.antiAir => const Color(0xFF7C4DFF),
    TowerType.machineGun => const Color(0xFF4FC3F7),
    TowerType.laser => const Color(0xFFFF3D9A),
    TowerType.techLab => const Color(0xFF1DE9B6),
    TowerType.rocketSilo => const Color(0xFFFF8A00),
    TowerType.commandPost => const Color(0xFFFFD54A),
    TowerType.artilleryBunker => const Color(0xFF8D6E63),
  };

  static Future<Sprite> base(TowerType type) async {
    final cached = _baseCache[type];
    if (cached != null) return cached;
    final image = await renderToImage(64, 64, (c) => _paintBase(c, type));
    return _baseCache[type] = Sprite(image);
  }

  static Future<Sprite> turret(TowerType type) async {
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

  static void _paintBase(Canvas canvas, TowerType type) {
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

  static void _paintTurret(Canvas canvas, TowerType type) {
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
      case TowerType.techLab:
        _paintTechLabTurret(canvas, center);
      case TowerType.rocketSilo:
        _paintRocketSiloTurret(canvas, center);
      case TowerType.commandPost:
        _paintCommandPostTurret(canvas, center);
      case TowerType.artilleryBunker:
        _paintArtilleryBunkerTurret(canvas, center);
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
}
