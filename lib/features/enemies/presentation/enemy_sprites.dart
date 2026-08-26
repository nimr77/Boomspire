import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../../../core/rendering/procedural_image.dart';
import '../domain/models/enemy_type.dart';

/// Procedurally paints the green-soldier "2D object models" - a regular
/// soldier and a bulkier, red-trimmed heavy soldier - cached after first
/// generation.
class EnemySpriteFactory {
  static Sprite? _soldier;

  static Sprite? _heavy;
  static Sprite? _helicopter;
  static Sprite? _tank;
  static Sprite? _attackPlane;
  static Sprite? _gunboat;
  EnemySpriteFactory._();

  /// The faction color for this enemy type - used for the ground fire-pulse
  /// effect when it shoots at a tower.
  static Color accentColor(EnemyType type) => switch (type) {
    EnemyType.soldier => const Color(0xFF4C7A2A),
    EnemyType.heavySoldier => const Color(0xFFB71C1C),
    EnemyType.tank => const Color(0xFF6D4C41),
    EnemyType.helicopter => const Color(0xFFE53935),
    EnemyType.attackPlane => const Color(0xFF00E5FF),
    EnemyType.gunboat => const Color(0xFF2E7D8C),
  };

  static Future<Sprite> gunboat() async {
    final cached = _gunboat;
    if (cached != null) return cached;
    final image = await renderToImage(70, 70, _paintGunboat);
    return _gunboat = Sprite(image);
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

  static Future<Sprite> soldier() async {
    final cached = _soldier;
    if (cached != null) return cached;
    final image = await renderToImage(48, 48, (c) => _paint(c, heavy: false));
    return _soldier = Sprite(image);
  }

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
        center: center.translate(0, size * 0.28),
        width: size * 0.55,
        height: size * 0.2,
      ),
      Paint()..color = const Color(0x59000000),
    );

    if (heavy) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(0, size * 0.08),
            width: size * 0.34,
            height: size * 0.4,
          ),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFF263A17),
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(-size * 0.12, size * 0.22),
          width: size * 0.16,
          height: size * 0.3,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = darkColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(size * 0.12, size * 0.22),
          width: size * 0.16,
          height: size * 0.3,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = darkColor,
    );

    final torsoRect = Rect.fromCenter(
      center: center.translate(0, -size * 0.02),
      width: size * 0.5,
      height: size * 0.42,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(torsoRect, const Radius.circular(8)),
      Paint()
        ..shader = LinearGradient(
          colors: [bodyColor, darkColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(torsoRect),
    );
    canvas.drawLine(
      Offset(center.dx, torsoRect.top + 2),
      Offset(center.dx, torsoRect.bottom - 2),
      Paint()
        ..color = darkColor
        ..strokeWidth = 2,
    );

    if (heavy) {
      canvas.drawCircle(
        center.translate(-size * 0.26, -size * 0.14),
        size * 0.11,
        Paint()..color = const Color(0xFFB71C1C),
      );
      canvas.drawCircle(
        center.translate(size * 0.26, -size * 0.14),
        size * 0.11,
        Paint()..color = const Color(0xFFB71C1C),
      );
    }

    final riflePaint = Paint()
      ..color = const Color(0xFF1a1a1a)
      ..strokeWidth = heavy ? 4 : 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center.translate(-size * 0.2, size * 0.22),
      center.translate(size * 0.14, -size * 0.42),
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

  static void _paintTank(Canvas canvas) {
    const size = 54.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.85, height: size * 0.3),
      Paint()..color = const Color(0x40000000),
    );

    // Treads - a dark track loop on either side of the hull.
    for (final dx in [-size * 0.28, size * 0.28]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, size * 0.06),
            width: size * 0.22,
            height: size * 0.56,
          ),
          const Radius.circular(8),
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

  static void _paintGunboat(Canvas canvas) {
    const size = 70.0;
    const center = Offset(size / 2, size / 2);

    // Wake shadow beneath the hull.
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.95, height: size * 0.4),
      Paint()..color = const Color(0x40000000),
    );

    // Hull - a wide boat-shaped silhouette (pointed bow, flat stern).
    final hull = Path()
      ..moveTo(center.dx, center.dy - size * 0.46)
      ..lineTo(center.dx + size * 0.28, center.dy + size * 0.3)
      ..lineTo(center.dx + size * 0.24, center.dy + size * 0.42)
      ..lineTo(center.dx - size * 0.24, center.dy + size * 0.42)
      ..lineTo(center.dx - size * 0.28, center.dy + size * 0.3)
      ..close();
    canvas.drawPath(
      hull,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF546E7A), Color(0xFF263238)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: size * 0.46)),
    );
    canvas.drawPath(
      hull,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF2E7D8C),
    );

    // Waterline stripe.
    canvas.drawLine(
      center.translate(-size * 0.26, size * 0.22),
      center.translate(size * 0.26, size * 0.22),
      Paint()
        ..color = const Color(0xFF2E7D8C)
        ..strokeWidth = 2,
    );

    // Deckhouse.
    final deckhouse = Rect.fromCenter(
      center: center.translate(0, size * 0.02),
      width: size * 0.24,
      height: size * 0.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(deckhouse, const Radius.circular(4)),
      Paint()..color = const Color(0xFF37474F),
    );

    // Forward deck cannon - the weapon this unit fires at towers.
    final cannonCenter = center.translate(0, -size * 0.16);
    canvas.drawCircle(
      cannonCenter,
      size * 0.13,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF8d8060), Color(0xFF2b2f36)],
        ).createShader(Rect.fromCircle(center: cannonCenter, radius: size * 0.13)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -size * 0.32),
          width: size * 0.08,
          height: size * 0.26,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF23262b),
    );

    // Radar mast + warning light, so it reads as a crewed hostile vessel.
    canvas.drawLine(
      center.translate(0, -size * 0.02),
      center.translate(0, -size * 0.24),
      Paint()
        ..color = const Color(0xFF1a1c20)
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(
      center.translate(0, size * 0.02),
      size * 0.03,
      Paint()..color = const Color(0xFFE53935),
    );
  }
}
