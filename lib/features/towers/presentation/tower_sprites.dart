import 'dart:math';

import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../../../core/rendering/procedural_image.dart';
import '../domain/models/tower_type.dart';

/// Procedurally paints tower base plates and turrets - our "2D object
/// models" for towers, cached per [TowerType] so art is generated once.
class TowerSpriteFactory {
  TowerSpriteFactory._();

  static final Map<TowerType, Sprite> _baseCache = {};
  static final Map<TowerType, Sprite> _turretCache = {};

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

  static void _paintBase(Canvas canvas, TowerType type) {
    const center = Offset(32, 32);
    final accent = type == TowerType.rocket
        ? const Color(0xFFFF6B35)
        : const Color(0xFF4FC3F7);

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

  static void _paintTurret(Canvas canvas, TowerType type) {
    const center = Offset(24, 24);
    if (type == TowerType.machineGun) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(-5, -8),
            width: 6,
            height: 26,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF2b2f36),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(5, -8),
            width: 6,
            height: 26,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF2b2f36),
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
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(0, -6),
            width: 14,
            height: 30,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF3a3f47),
      );
      canvas.drawCircle(
        Offset(center.dx, center.dy - 21),
        7,
        Paint()..color = const Color(0xFF1a1c20),
      );
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
    }
  }
}
