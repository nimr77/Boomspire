import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Paints all of a `TowerComponent`'s render-time overlays: the selection
/// ring (range ring, dead-zone ring, breathing star), the idle breathing
/// glow, upgrade-tier chevrons, shield bubble, and HP bar.
void paintTowerOverlay(
  Canvas canvas, {
  required bool selected,
  required double idlePhase,
  required Color accent,
  required double effectiveRange,
  required double minRange,
  required int upgradeLevel,
  required int shieldMax,
  required int shield,
  required double hp,
  required double maxHp,
  required Vector2 size,
}) {
  final center = Offset(size.x / 2, size.y / 2);

  if (selected) {
    // Pulsing range ring - tapping a built tower reveals its coverage,
    // same as the pre-build ghost preview.
    if (effectiveRange > 0) {
      final rangePulse = 0.5 + 0.5 * sin(idlePhase * 1.6);
      canvas.drawCircle(
        center,
        effectiveRange,
        Paint()..color = accent.withValues(alpha: 0.04 + rangePulse * 0.04),
      );
      canvas.drawCircle(
        center,
        effectiveRange,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 + rangePulse
          ..color = accent.withValues(alpha: 0.35 + rangePulse * 0.3),
      );
    }

    // Dead-zone ring - a hatched red disc marking the minimum engagement
    // radius for long-range-only weapons (e.g. the Rocket Silo), so it
    // reads clearly as "can't fire in here" rather than just less range.
    if (minRange > 0) {
      canvas.drawCircle(
        center,
        minRange,
        Paint()..color = const Color(0xFFE53935).withValues(alpha: 0.18),
      );
      canvas.drawCircle(
        center,
        minRange,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFFE53935).withValues(alpha: 0.6),
      );
    }

    final pulse = 0.5 + 0.5 * sin(idlePhase * 1.6);
    final outerR = size.x * 0.85 + pulse * 3;
    final innerR = outerR * 0.55;
    final rotation = idlePhase * 0.25;
    final star = Path();
    for (var i = 0; i < 16; i++) {
      final r = i.isEven ? outerR : innerR;
      final a = rotation + i * pi / 8;
      final pt = center.translate(cos(a) * r, sin(a) * r);
      if (i == 0) {
        star.moveTo(pt.dx, pt.dy);
      } else {
        star.lineTo(pt.dx, pt.dy);
      }
    }
    star.close();
    canvas.drawPath(
      star,
      Paint()
        ..color = accent.withValues(alpha: 0.14 + pulse * 0.06)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      star,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withValues(alpha: 0.75 + pulse * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  // Subtle idle "breathing" glow ring so an undamaged tower still reads
  // as active/crewed hardware rather than a static prop.
  final breath = 0.5 + 0.5 * sin(idlePhase);
  canvas.drawCircle(
    center,
    size.x * 0.42 + breath * 1.5,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = accent.withValues(alpha: 0.12 + breath * 0.1),
  );

  // Tier rank chevrons - a quick, unmistakable "this tower got upgraded"
  // read, stacked above the HP bar, one per upgrade level.
  for (var i = 0; i < upgradeLevel; i++) {
    final cy = -18.0 - i * 6;
    final chevron = Path()
      ..moveTo(size.x / 2 - 6, cy + 4)
      ..lineTo(size.x / 2, cy)
      ..lineTo(size.x / 2 + 6, cy + 4);
    canvas.drawPath(
      chevron,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFD54A),
    );
  }

  // Shield bubble - only present once the first upgrade grants one,
  // opacity/thickness scale with how much charge is currently banked.
  if (shieldMax > 0) {
    final shieldRatio = (shield / shieldMax).clamp(0.0, 1.0).toDouble();
    if (shieldRatio > 0) {
      canvas.drawCircle(
        center,
        size.x * 0.56,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 + shieldRatio * 1.5
          ..color = const Color(0xFF40C4FF)
              .withValues(alpha: 0.25 + shieldRatio * 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  if (hp >= maxHp) return;
  final ratio = (hp / maxHp).clamp(0.0, 1.0);
  final barWidth = size.x * 0.85;
  final barX = (size.x - barWidth) / 2;
  const barY = -10.0;
  canvas.drawRect(
    Rect.fromLTWH(barX, barY, barWidth, 4),
    Paint()..color = const Color(0xAA000000),
  );
  canvas.drawRect(
    Rect.fromLTWH(barX, barY, barWidth * ratio, 4),
    Paint()
      ..color = ratio > 0.5 ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
  );
}
