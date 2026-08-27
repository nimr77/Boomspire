import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../../../core/combat/attackable.dart';
import '../../../core/combat/team.dart';
import '../../../core/combat/unit.dart';
import '../../../core/rendering/procedural_image.dart';
import '../domain/models/game_config.dart';
import 'boomspire_game.dart';

/// The player's home base at the terrain's end point: a defended structure
/// (instead of a plain marker circle) that shows its remaining health and
/// flashes/pulses red whenever the player takes damage. Implements
/// [Attackable] so a [GameMode.skirmish] opponent's units can walk up and
/// destroy it directly, same as they would a tower - its actual HP still
/// lives in [GameStateRepository.health] (the single human player's wallet),
/// not on this component.
class HomeBaseComponent extends PositionComponent
    with HasGameReference<BoomspireGame>, Unit
    implements Attackable {
  static ui.Image? _cachedSprite;

  /// Always the human player's team today - kept as a field (rather than
  /// just reading `game.playerTeam`) so `opposingTargets()` can treat this
  /// the same way it treats an owned tower.
  final Team owner;

  late final SpriteComponent _visual;
  int _lastHealth = 0;
  double _pulse = 0;

  HomeBaseComponent({required Vector2 position, this.owner = Team.defaultPlayer})
    : super(
        position: position,
        size: Vector2.all(84),
        anchor: Anchor.center,
        priority: 6,
      );

  @override
  Set<UnitDomain> get attackDomains => const {};

  @override
  bool get destroyed => game.gameState.health <= 0;

  @override
  UnitDomain get domain => UnitDomain.ground;

  @override
  double get healthRatio =>
      (game.gameState.health / GameConfig.startingHealth).clamp(0.0, 1.0);

  @override
  void takeDamage(double amount) => game.gameState.damagePlayer(amount.round());

  @override
  Future<void> onLoad() async {
    _lastHealth = game.gameState.health;
    final image = _cachedSprite ??= await renderToImage(96, 96, _paintHome);
    _visual = SpriteComponent(
      sprite: Sprite(image),
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    await add(_visual);
  }

  @override
  void render(ui.Canvas canvas) {
    if (_pulse > 0) {
      final radius = size.x * (0.55 + (1 - _pulse) * 0.55);
      canvas.drawCircle(
        ui.Offset(size.x / 2, size.y / 2),
        radius,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = const ui.Color(0xFFE53935).withValues(alpha: _pulse * 0.85),
      );
    }

    final ratio = (game.gameState.health / GameConfig.startingHealth).clamp(
      0.0,
      1.0,
    );
    final barWidth = size.x * 0.9;
    final barX = (size.x - barWidth) / 2;
    const barY = -12.0;
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(barX, barY, barWidth, 6),
        const ui.Radius.circular(3),
      ),
      ui.Paint()..color = const ui.Color(0xAA000000),
    );
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(barX, barY, barWidth * ratio, 6),
        const ui.Radius.circular(3),
      ),
      ui.Paint()
        ..color = ratio > 0.4
            ? const ui.Color(0xFF00E5FF)
            : const ui.Color(0xFFE53935),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final health = game.gameState.health;
    if (health < _lastHealth) _pulse = 1;
    _lastHealth = health;
    if (_pulse > 0) _pulse = (_pulse - dt * 1.6).clamp(0, 1);
  }

  static void _paintHome(ui.Canvas canvas) {
    const size = 96.0;
    const center = ui.Offset(size / 2, size / 2 + 6);

    canvas.drawOval(
      ui.Rect.fromCenter(
        center: center.translate(0, size * 0.34),
        width: size * 0.7,
        height: size * 0.16,
      ),
      ui.Paint()..color = const ui.Color(0x59000000),
    );

    final wallRect = ui.Rect.fromCenter(
      center: center.translate(0, size * 0.08),
      width: size * 0.62,
      height: size * 0.42,
    );
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(wallRect, const ui.Radius.circular(8)),
      ui.Paint()
        ..shader = ui.Gradient.linear(
          ui.Offset(wallRect.left, wallRect.top),
          ui.Offset(wallRect.left, wallRect.bottom),
          [const ui.Color(0xFF37474F), const ui.Color(0xFF1B242A)],
        ),
    );
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(wallRect, const ui.Radius.circular(8)),
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const ui.Color(0xFF00E5FF).withValues(alpha: 0.6),
    );

    // Roof - a simple house silhouette so the base reads as "home".
    final roofPath = ui.Path()
      ..moveTo(center.dx - size * 0.38, wallRect.top + 2)
      ..lineTo(center.dx, wallRect.top - size * 0.24)
      ..lineTo(center.dx + size * 0.38, wallRect.top + 2)
      ..close();
    canvas.drawPath(roofPath, ui.Paint()..color = const ui.Color(0xFF263238));
    canvas.drawPath(
      roofPath,
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const ui.Color(0xFF00E5FF).withValues(alpha: 0.8),
    );

    // Energy-core door glow.
    final doorCenter = center.translate(0, size * 0.12);
    canvas.drawCircle(
      doorCenter,
      size * 0.1,
      ui.Paint()
        ..shader = ui.Gradient.radial(doorCenter, size * 0.1, [
          const ui.Color(0xFF80F6FF),
          const ui.Color(0xFF00838F),
        ]),
    );

    // Antenna.
    final antennaTop = ui.Offset(center.dx, wallRect.top - size * 0.38);
    canvas.drawLine(
      ui.Offset(center.dx, wallRect.top - size * 0.24),
      antennaTop,
      ui.Paint()
        ..color = const ui.Color(0xFF00E5FF)
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      antennaTop,
      3,
      ui.Paint()..color = const ui.Color(0xFF00E5FF),
    );
  }
}
