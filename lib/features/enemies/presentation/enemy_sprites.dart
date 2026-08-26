import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../../../core/rendering/procedural_image.dart';

/// Procedurally paints the green-soldier "2D object models" - a regular
/// soldier and a bulkier, red-trimmed heavy soldier - cached after first
/// generation.
class EnemySpriteFactory {
  EnemySpriteFactory._();

  static Sprite? _soldier;
  static Sprite? _heavy;

  static Future<Sprite> soldier() async {
    final cached = _soldier;
    if (cached != null) return cached;
    final image = await renderToImage(48, 48, (c) => _paint(c, heavy: false));
    return _soldier = Sprite(image);
  }

  static Future<Sprite> heavySoldier() async {
    final cached = _heavy;
    if (cached != null) return cached;
    final image = await renderToImage(60, 60, (c) => _paint(c, heavy: true));
    return _heavy = Sprite(image);
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
    canvas.drawRect(
      Rect.fromCenter(
        center: center.translate(0, -size * 0.3),
        width: size * 0.22,
        height: size * 0.05,
      ),
      Paint()..color = const Color(0xFF0d1a06),
    );
  }
}
