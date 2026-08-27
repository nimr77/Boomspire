import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

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
  AllySpriteFactory._();

  static const _hull = Color(0xFF2B3A42);
  static const _hullDark = Color(0xFF172126);
  static const _accent = Color(0xFF00E5FF);

  static Future<Sprite> aircraft() async {
    final cached = _aircraft;
    if (cached != null) return cached;
    final image = await renderToImage(50, 50, _paintAircraft);
    return _aircraft = Sprite(image);
  }

  static Future<Sprite> lightVehicle() async {
    final cached = _lightVehicle;
    if (cached != null) return cached;
    final image = await renderToImage(46, 46, _paintLightVehicle);
    return _lightVehicle = Sprite(image);
  }

  static Future<Sprite> soldier() async {
    final cached = _soldier;
    if (cached != null) return cached;
    final image = await renderToImage(48, 48, _paintSoldier);
    return _soldier = Sprite(image);
  }

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

    // Wheels.
    for (final dy in [-size * 0.24, size * 0.24]) {
      for (final dx in [-size * 0.32, size * 0.32]) {
        canvas.drawCircle(
          center.translate(dx, dy),
          size * 0.1,
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
        center: center.translate(0, size * 0.28),
        width: size * 0.55,
        height: size * 0.2,
      ),
      Paint()..color = const Color(0x59000000),
    );

    for (final dx in [-size * 0.12, size * 0.12]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(dx, size * 0.22),
            width: size * 0.16,
            height: size * 0.3,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = _hullDark,
      );
    }

    final torsoRect = Rect.fromCenter(
      center: center.translate(0, -size * 0.02),
      width: size * 0.5,
      height: size * 0.42,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(torsoRect, const Radius.circular(8)),
      Paint()
        ..shader = const LinearGradient(
          colors: [_hull, _hullDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(torsoRect),
    );
    canvas.drawLine(
      Offset(center.dx, torsoRect.top + 2),
      Offset(center.dx, torsoRect.bottom - 2),
      Paint()
        ..color = _accent.withValues(alpha: 0.7)
        ..strokeWidth = 2,
    );

    final rifle = Paint()
      ..color = const Color(0xFF1a1a1a)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center.translate(-size * 0.2, size * 0.22),
      center.translate(size * 0.14, -size * 0.42),
      rifle,
    );

    canvas.drawCircle(
      center.translate(0, -size * 0.3),
      size * 0.17,
      Paint()..color = _hullDark,
    );
    canvas.drawCircle(
      center.translate(0, -size * 0.32),
      size * 0.15,
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

  static void _paintTank(Canvas canvas) {
    const size = 54.0;
    const center = Offset(size / 2, size / 2);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 0.85, height: size * 0.3),
      Paint()..color = const Color(0x40000000),
    );

    // Treads.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size * 0.9, height: size * 0.62),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF1a1c20),
    );

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
        ..shader = const LinearGradient(
          colors: [_hull, _hullDark],
        ).createShader(
          Rect.fromCircle(center: center, radius: size * 0.2),
        ),
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
